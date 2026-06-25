const fs = require('fs');
const path = require('path');

const srcDir = __dirname;
const mainFile = path.join(srcDir, 'main.lua');

if (!fs.existsSync(mainFile)) {
    console.error("main.lua not found in " + srcDir);
    process.exit(1);
}

let __MODULES = {};

function resolveModulePath(modulePath) {
    let tryPaths = [
        path.join(srcDir, modulePath.replace(/^(SUB_DIR\s*\.\.\s*")/, "").replace(/"$/, "")),
        path.join(srcDir, 'mobilever', modulePath),
        path.join(srcDir, modulePath)
    ];
    for (let p of tryPaths) {
        if (fs.existsSync(p)) return p;
    }
    return null;
}

function scanAndBundle(filePath, visited = new Set()) {
    if (visited.has(filePath)) return;
    visited.add(filePath);
    let content = fs.readFileSync(filePath, 'utf8');

    const regex = /load_module\s*\(\s*(.*?)\s*\)/g;
    let match;
    while ((match = regex.exec(content)) !== null) {
        let moduleNameRaw = match[1];
        let moduleName = moduleNameRaw;
        if (moduleNameRaw.includes('SUB_DIR')) {
            moduleName = moduleNameRaw.replace('SUB_DIR', '""').replace(/\.\./g, '..');
            try { moduleName = moduleNameRaw.replace(/SUB_DIR\s*\.\./g, "").replace(/"/g, "").trim(); } catch(e) {}
        } else {
             moduleName = moduleNameRaw.replace(/"/g, "").trim();
        }
        let resolvedPath = resolveModulePath(moduleName);
        if (resolvedPath && fs.existsSync(resolvedPath)) {
            let relativeName = moduleName;
            if (!__MODULES[relativeName]) {
                 __MODULES[relativeName] = fs.readFileSync(resolvedPath, 'utf8');
                 scanAndBundle(resolvedPath, visited);
            }
        }
    }
}

const shapesDir = path.join(srcDir, 'shapes');
if (fs.existsSync(shapesDir)) {
    const shapes = fs.readdirSync(shapesDir);
    for (let shape of shapes) {
        if (shape.endsWith('.lua')) {
            let shapeName = shape.replace('.lua', '');
            // Only store the shape once!
            __MODULES["shapes/" + shapeName + ".lua"] = fs.readFileSync(path.join(shapesDir, shape), 'utf8');
        }
    }
}

const standardFiles = [
    'config.lua',
    'math/serialization.lua',
    'System.lua',
    'System_sculptor.lua',
    'UI.lua',
    'UI_elements.lua',
    'mobilever/System.lua',
    'mobilever/System_sculptor.lua',
    'mobilever/UI.lua',
    'mobilever/UI_elements.lua'
];

for (let file of standardFiles) {
    let fullPath = path.join(srcDir, file);
    if (fs.existsSync(fullPath)) {
        __MODULES[file] = fs.readFileSync(fullPath, 'utf8');
    }
}

let mainContent = fs.readFileSync(mainFile, 'utf8');

let bundleOutput = `-- BUNDLED WITH MAXITOM BUNDLER\n\n`;
bundleOutput += `local __MODULES = {}\n\n`;

for (let modName in __MODULES) {
    let safeName = modName.replace(/\\/g, '\\\\').replace(/"/g, '\\"');
    bundleOutput += `__MODULES["${safeName}"] = function()\n`;
    bundleOutput += __MODULES[modName];
    bundleOutput += `\nend\n\n`;
}

const newLoadModule = `local function load_module(path)
    local normalizedPath = string.gsub(path, "^mobilever/", "")
    if __MODULES[path] then
        return __MODULES[path]()
    elseif __MODULES[normalizedPath] then
        return __MODULES[normalizedPath]()
    end
    warn("Failed to find bundled module: " .. tostring(path))
    return nil
end`;

const newGetShape = `local function get_shape(name)
    if not loaded_shapes[name] then
        local path1 = "shapes/" .. tostring(name) .. ".lua"
        local success, res = false, nil
        if __MODULES[path1] then
            success, res = pcall(__MODULES[path1])
        end
        if success then 
            loaded_shapes[name] = res 
        else
            warn("Failed to find/execute bundled shape: " .. tostring(name))
        end
    end
    return loaded_shapes[name]
end`;

const oldLoadModule = `local function load_module(path)
	local code = safe_http_get(BASE_URL .. path)
	if code then
		local func, err = loadstring(code)
		if func then
			return func()
		end
		warn("Syntax error in module " .. path .. ": " .. tostring(err))
	end
	warn("Failed to download module: " .. path)
	return nil
end`;

const oldGetShape = `local function get_shape(name)
	if not loaded_shapes[name] then
		local url = BASE_URL .. "shapes/" .. HttpService:UrlEncode(name) .. ".lua"
		local code = safe_http_get(url)
		local success, result = false, nil
		if code then
			local func = loadstring(code)
			if func then
				success, result = pcall(func)
			else
				result = "Syntax error in shape source"
			end
		else
			result = "HTTP Request Failed"
		end
		if success and result then
			loaded_shapes[name] = result
		else
			warn("Failed to load shape: " .. tostring(name) .. " Error: " .. tostring(result))
		end
	end
	return loaded_shapes[name]
end`;

mainContent = mainContent.replace(oldLoadModule, newLoadModule);
mainContent = mainContent.replace(oldGetShape, newGetShape);

bundleOutput += "\n\n" + mainContent;

fs.writeFileSync(path.join(srcDir, 'bundle.lua'), bundleOutput);
console.log("Successfully bundled project gravity to bundle.lua");
