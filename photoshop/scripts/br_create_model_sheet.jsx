#target photoshop

/**
 * Model Sheet Creator Script
 * Automatically creates a model sheet with smart object layers
 * linked to PNG files containing keywords: front, back, left, right, hero
 * 
 * Layout: Front/Left/Right/Back in 2x2 grid (left side, 1/2 height each)
 *         Hero image (right side, full height)
 * 
 * Author: Bay Raitt
 * Date: 2025
 */

// Create new document and run main function
main();

function main() {
    try {
        // Get target folder from user first
        var targetFolder = Folder.selectDialog("Select folder containing PNG files:");
        
        if (!targetFolder) {
            alert("No folder selected. Script cancelled.");
            return;
        }
        
        // Create document name from folder name
        var folderName = targetFolder.name;
        var docName = folderName + "_modelsheet_v.000";
        
        // Find next available version number for PSD (don't overwrite existing)
        docName = getNextAvailableVersion(targetFolder, folderName);
        
        // Create a new 2048x2048 document
        var doc = app.documents.add(2048, 2048, 72, docName);
        
        // Define the keywords to search for
        var keywords = ["front", "back", "left", "right", "hero"];
        
        // Find PNG files matching keywords
        var matchedFiles = findMatchingFiles(targetFolder, keywords);
        
        if (matchedFiles.length === 0) {
            alert("No PNG files found with keywords: " + keywords.join(", "));
            // Close the document since no files were found
            doc.close(SaveOptions.DONOTSAVECHANGES);
            return;
        }
        
        // Create model sheet with custom layout
        createCustomModelSheet(doc, matchedFiles, targetFolder, folderName);
        
        // Save the document to the source folder (PSD and JPG)
        var saveFileName = docName + ".psd";
        var jpgFileName = folderName + "_modelsheet.jpg"; // Remove version number for JPG
        var saveFile = new File(targetFolder + "/" + saveFileName);
        var jpgFile = new File(targetFolder + "/" + jpgFileName);
        
        // Export as JPG first (to avoid marking document as dirty)
        var exportOptions = new ExportOptionsSaveForWeb();
        exportOptions.format = SaveDocumentType.JPEG;
        exportOptions.quality = 80; // Higher quality for model sheets
        doc.exportDocument(jpgFile, ExportType.SAVEFORWEB, exportOptions);
        
        // Save as PSD after JPEG export
        doc.saveAs(saveFile);
        
    } catch (error) {
        alert("Error: " + error.message);
    }
}

/**
 * Find PNG files in the target folder that contain any of the specified keywords
 * @param {Folder} folder - The folder to search in
 * @param {Array} keywords - Array of keywords to search for
 * @returns {Array} Array of objects with file and keyword information
 */
function findMatchingFiles(folder, keywords) {
    var matchedFiles = [];
    var files = folder.getFiles("*.png");
    
    for (var i = 0; i < files.length; i++) {
        var file = files[i];
        var fileName = file.name.toLowerCase();
        
        for (var j = 0; j < keywords.length; j++) {
            var keyword = keywords[j].toLowerCase();
            
            if (fileName.indexOf(keyword) !== -1) {
                matchedFiles.push({
                    file: file,
                    keyword: keywords[j], // Keep original case for layer name
                    fileName: file.name
                });
                break; // Only match first keyword found to avoid duplicates
            }
        }
    }
    
    return matchedFiles;
}

/**
 * Create model sheet with custom layout
 * Front/Left/Right/Back in 2x2 grid (left side, 1/2 height each)
 * Hero image (right side, full height)
 * @param {Document} doc - The active Photoshop document
 * @param {Array} matchedFiles - Array of matched file objects
 * @param {Folder} targetFolder - The source folder containing PNG files
 * @param {String} folderName - The name of the source folder
 */
function createCustomModelSheet(doc, matchedFiles, targetFolder, folderName) {
    // Set up document units
    var originalRulerUnits = app.preferences.rulerUnits;
    app.preferences.rulerUnits = Units.PIXELS;
    
    try {
        var docWidth = 2048;
        var docHeight = 2048;
        
        // Create 50% gray background layer
        createGrayBackground(doc);
        
        // Separate files by type
        var heroFile = null;
        var frontFile = null;
        var gridFiles = [];
        
        for (var i = 0; i < matchedFiles.length; i++) {
            var fileInfo = matchedFiles[i];
            if (fileInfo.keyword.toLowerCase() === "hero") {
                heroFile = fileInfo;
            } else if (fileInfo.keyword.toLowerCase() === "front") {
                frontFile = fileInfo;
                gridFiles.push(fileInfo);
            } else {
                gridFiles.push(fileInfo);
            }
        }
        
        // If no hero file found, look for folder name PNG file (e.g., "eric.png")
        if (!heroFile) {
            var folderNameFile = new File(targetFolder + "/" + folderName + ".png");
            if (folderNameFile.exists) {
                heroFile = {
                    file: folderNameFile,
                    keyword: "hero",
                    fileName: folderNameFile.name
                };
            }
        }
        
        // If still no hero file found, use front file as hero
        if (!heroFile && frontFile) {
            heroFile = frontFile;
            // Remove front file from grid files since it's now the hero
            for (var i = gridFiles.length - 1; i >= 0; i--) {
                if (gridFiles[i] === frontFile) {
                    gridFiles.splice(i, 1);
                    break;
                }
            }
        }
        
        // Create hero image (right side, full height)
        if (heroFile) {
            var heroWidth = 1024; // Half the document width for 1:2 ratio at full height
            var heroHeight = 2048; // Full document height
            var heroX = docWidth - (heroWidth / 2); // Right side, centered
            var heroY = docHeight / 2; // Vertically centered
            
            createSmartObjectLayer(doc, heroFile, heroX, heroY, heroWidth, heroHeight);
        }
        
        // Create grid images (left side, 2x2 grid)
        if (gridFiles.length > 0) {
            // Define positions for 2x2 grid on left side
            var gridWidth = 1024; // Left half of document
            var gridHeight = 2048; // Full height
            var cellWidth = gridWidth / 2; // 512 pixels wide
            var cellHeight = gridHeight / 2; // 1024 pixels tall
            
            // Target size for each grid image (1/2 document height)
            var targetWidth = 512; // Width for 1:2 ratio at half height
            var targetHeight = 1024; // Half the document height
            
            // Define grid positions
            var positions = [
                {x: cellWidth / 2, y: cellHeight / 2, label: "top-left"},
                {x: cellWidth + (cellWidth / 2), y: cellHeight / 2, label: "top-right"},
                {x: cellWidth / 2, y: cellHeight + (cellHeight / 2), label: "bottom-left"},
                {x: cellWidth + (cellWidth / 2), y: cellHeight + (cellHeight / 2), label: "bottom-right"}
            ];
            
            // Preferred order for grid placement
            var preferredOrder = ["front", "right", "left", "back"];
            var sortedGridFiles = [];
            
            // Sort files by preferred order
            for (var p = 0; p < preferredOrder.length; p++) {
                for (var g = 0; g < gridFiles.length; g++) {
                    if (gridFiles[g].keyword.toLowerCase() === preferredOrder[p]) {
                        sortedGridFiles.push(gridFiles[g]);
                        break;
                    }
                }
            }
            
            // Add any remaining files not in preferred order
            for (var g = 0; g < gridFiles.length; g++) {
                var found = false;
                for (var s = 0; s < sortedGridFiles.length; s++) {
                    if (sortedGridFiles[s] === gridFiles[g]) {
                        found = true;
                        break;
                    }
                }
                if (!found) {
                    sortedGridFiles.push(gridFiles[g]);
                }
            }
            
            // Place grid files
            for (var i = 0; i < Math.min(sortedGridFiles.length, positions.length); i++) {
                var fileInfo = sortedGridFiles[i];
                var pos = positions[i];
                
                createSmartObjectLayer(doc, fileInfo, pos.x, pos.y, targetWidth, targetHeight);
            }
        }
        
    } finally {
        // Restore original ruler units
        app.preferences.rulerUnits = originalRulerUnits;
    }
}

/**
 * Create a 50% gray background layer
 * @param {Document} doc - The active document
 */
function createGrayBackground(doc) {
    try {
        // Remove the default Background layer if it exists using Action Manager
        try {
            // First check if there's a background layer
            var backgroundLayer = doc.backgroundLayer;
            if (backgroundLayer) {
                // Convert background to regular layer first, then delete
                var idsetd = charIDToTypeID("setd");
                var desc = new ActionDescriptor();
                var idnull = charIDToTypeID("null");
                var ref = new ActionReference();
                var idLyr = charIDToTypeID("Lyr ");
                var idBckg = charIDToTypeID("Bckg");
                ref.putEnumerated(idLyr, idLyr, idBckg);
                desc.putReference(idnull, ref);
                var idT = charIDToTypeID("T   ");
                var layerDesc = new ActionDescriptor();
                var idOpct = charIDToTypeID("Opct");
                var idPrc = charIDToTypeID("#Prc");
                layerDesc.putUnitDouble(idOpct, idPrc, 100.000000);
                var idLyr = charIDToTypeID("Lyr ");
                desc.putObject(idT, idLyr, layerDesc);
                executeAction(idsetd, desc, DialogModes.NO);
                
                // Now delete the converted layer
                var idDlt = charIDToTypeID("Dlt ");
                var desc2 = new ActionDescriptor();
                var idnull = charIDToTypeID("null");
                var ref2 = new ActionReference();
                var idLyr = charIDToTypeID("Lyr ");
                var idOrdn = charIDToTypeID("Ordn");
                var idTrgt = charIDToTypeID("Trgt");
                ref2.putEnumerated(idLyr, idOrdn, idTrgt);
                desc2.putReference(idnull, ref2);
                executeAction(idDlt, desc2, DialogModes.NO);
            }
        } catch (e) {
            // Background layer doesn't exist or can't be removed - continue anyway
        }
        
        // Create solid color layer using Action Manager (proper way)
        var idMk = charIDToTypeID("Mk  ");
        var desc = new ActionDescriptor();
        var idnull = charIDToTypeID("null");
        var ref = new ActionReference();
        var idcontentLayer = stringIDToTypeID("contentLayer");
        ref.putClass(idcontentLayer);
        desc.putReference(idnull, ref);
        var idUsng = charIDToTypeID("Usng");
        var layerDesc = new ActionDescriptor();
        var idType = charIDToTypeID("Type");
        var colorDesc = new ActionDescriptor();
        var idClr = charIDToTypeID("Clr ");
        var rgbDesc = new ActionDescriptor();
        var idRd = charIDToTypeID("Rd  ");
        rgbDesc.putDouble(idRd, 128); // 50% gray
        var idGrn = charIDToTypeID("Grn ");
        rgbDesc.putDouble(idGrn, 128); // 50% gray
        var idBl = charIDToTypeID("Bl  ");
        rgbDesc.putDouble(idBl, 128); // 50% gray
        var idRGBC = charIDToTypeID("RGBC");
        colorDesc.putObject(idClr, idRGBC, rgbDesc);
        var idsolidColorLayer = stringIDToTypeID("solidColorLayer");
        layerDesc.putObject(idType, idsolidColorLayer, colorDesc);
        var idcontentLayer = stringIDToTypeID("contentLayer");
        desc.putObject(idUsng, idcontentLayer, layerDesc);
        executeAction(idMk, desc, DialogModes.NO);
        
        // Get the newly created layer
        var newLayer = doc.activeLayer;
        
        // Delete any layer mask that was created
        try {
            var idDlt = charIDToTypeID("Dlt ");
            var desc3 = new ActionDescriptor();
            var idnull = charIDToTypeID("null");
            var ref3 = new ActionReference();
            var idChnl = charIDToTypeID("Chnl");
            var idOrdn = charIDToTypeID("Ordn");
            var idTrgt = charIDToTypeID("Trgt");
            ref3.putEnumerated(idChnl, idOrdn, idTrgt);
            desc3.putReference(idnull, ref3);
            executeAction(idDlt, desc3, DialogModes.NO);
        } catch (e) {
            // No mask to delete
        }
        
        // Rename the layer
        newLayer.name = "Gray Background";
        
        // Move the background layer to the bottom
        newLayer.move(doc, ElementPlacement.PLACEATEND);
        
        // Try to remove any remaining background layers
        try {
            // Look for any layers named "Background" and remove them
            for (var i = doc.layers.length - 1; i >= 0; i--) {
                var layer = doc.layers[i];
                if (layer.name.toLowerCase() === "background" && layer !== newLayer) {
                    layer.remove();
                }
            }
        } catch (e) {
            // Could not remove background layers
        }
        
    } catch (error) {
        throw new Error("Failed to create gray background: " + error.message);
    }
}

/**
 * Create a smart object layer linked to the specified file
 * @param {Document} doc - The active document
 * @param {Object} fileInfo - File information object
 * @param {Number} x - X position (center point)
 * @param {Number} y - Y position (center point)
 * @param {Number} targetWidth - Target width for the smart object
 * @param {Number} targetHeight - Target height for the smart object
 */
function createSmartObjectLayer(doc, fileInfo, x, y, targetWidth, targetHeight) {
    try {
        // Place the file as a linked smart object using File menu approach
        try {
            // Use the Place command with linked option
            var idPlc = charIDToTypeID("Plc ");
            var desc = new ActionDescriptor();
            var idnull = charIDToTypeID("null");
            desc.putPath(idnull, fileInfo.file);
            var idFTcs = charIDToTypeID("FTcs");
            var idQCSt = charIDToTypeID("QCSt");
            var idQcsa = charIDToTypeID("Qcsa");
            desc.putEnumerated(idFTcs, idQCSt, idQcsa);
            // Add linked property
            var idLnkd = charIDToTypeID("Lnkd");
            desc.putBoolean(idLnkd, true);
            executeAction(idPlc, desc, DialogModes.NO);
        } catch (e) {
            // Fallback to regular embedded smart object if linked doesn't work
            var idPlc = charIDToTypeID("Plc ");
            var desc = new ActionDescriptor();
            var idnull = charIDToTypeID("null");
            desc.putPath(idnull, fileInfo.file);
            var idFTcs = charIDToTypeID("FTcs");
            var idQCSt = charIDToTypeID("QCSt");
            var idQcsa = charIDToTypeID("Qcsa");
            desc.putEnumerated(idFTcs, idQCSt, idQcsa);
            executeAction(idPlc, desc, DialogModes.NO);
        }
        
        // Get the newly created layer
        var smartObjectLayer = doc.activeLayer;
        
        // Rename the layer with keyword only
        smartObjectLayer.name = fileInfo.keyword;
        
        // Get current bounds for scaling calculation
        var bounds = smartObjectLayer.bounds;
        var currentWidth = bounds[2].value - bounds[0].value;
        var currentHeight = bounds[3].value - bounds[1].value;
        
        // Calculate scale to fit within target dimensions while maintaining aspect ratio
        // Use a slightly smaller scale to ensure it fits completely within the cell
        var scaleX = (targetWidth * 0.95) / currentWidth; // 95% to add padding
        var scaleY = (targetHeight * 0.95) / currentHeight; // 95% to add padding
        var scale = Math.min(scaleX, scaleY) * 100; // Convert to percentage and use smaller scale
        
        // Ensure minimum reasonable scale
        if (scale < 5) scale = 5; // Prevent extremely small images
        if (scale > 200) scale = 200; // Prevent extremely large images
        
        // Scale the smart object from center
        if (scale !== 100) {
            smartObjectLayer.resize(scale, scale, AnchorPosition.MIDDLECENTER);
        }
        
        // Get new bounds after scaling for accurate positioning
        var scaledBounds = smartObjectLayer.bounds;
        var scaledWidth = scaledBounds[2].value - scaledBounds[0].value;
        var scaledHeight = scaledBounds[3].value - scaledBounds[1].value;
        
        // Calculate current center after scaling
        var currentCenterX = (scaledBounds[0].value + scaledBounds[2].value) / 2;
        var currentCenterY = (scaledBounds[1].value + scaledBounds[3].value) / 2;
        
        // Calculate translation needed to center in target position
        var deltaX = x - currentCenterX;
        var deltaY = y - currentCenterY;
        
        // Apply the translation
        smartObjectLayer.translate(deltaX, deltaY);
        
    } catch (error) {
        throw new Error("Failed to create smart object for " + fileInfo.fileName + ": " + error.message);
    }
}

/**
 * Get current timestamp for unique naming
 * @returns {String} Formatted timestamp
 */
function getTimeStamp() {
    var now = new Date();
    var year = now.getFullYear();
    var month = zeroPad(now.getMonth() + 1, 2);
    var day = zeroPad(now.getDate(), 2);
    var hours = zeroPad(now.getHours(), 2);
    var minutes = zeroPad(now.getMinutes(), 2);
    var seconds = zeroPad(now.getSeconds(), 2);
    
    return year + month + day + "_" + hours + minutes + seconds;
}

/**
 * Zero-pad a number to specified places
 * @param {Number} num - Number to pad
 * @param {Number} places - Number of places
 * @returns {String} Zero-padded string
 */
function zeroPad(num, places) {
    var numZeroes = places - num.toString().length + 1;
    return Array(+(numZeroes > 0 && numZeroes)).join("0") + num;
}

/**
 * Find next available version number for PSD (don't overwrite existing)
 * @param {Folder} targetFolder - The source folder containing PSD files
 * @param {String} folderName - The name of the source folder
 * @returns {String} Next available version number
 */
function getNextAvailableVersion(targetFolder, folderName) {
    var version = 0;
    
    while (true) {
        var docName = folderName + "_modelsheet_v." + zeroPad(version, 3);
        var saveFileName = docName + ".psd";
        var saveFile = new File(targetFolder + "/" + saveFileName);
        
        if (!saveFile.exists) {
            return docName;
        }
        
        version++;
    }
} 