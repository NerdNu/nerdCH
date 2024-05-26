<!
	strict;
	requiredExtensions: CHFiles
>

// This script takes an input folder full of music and merges them into a resource pack. Files with the same
// name will be overwritten, but other files will not be. This uses ffmpeg, which can be found
// here https://ffmpeg.org/download.html and CHFiles which can be found https://letsbuild.net/jenkins/job/CHFiles/
// (Place the extension in your MethodScript folder.)

@ffmpegPath = get_absolute_path($1);
@inputDirectory = get_absolute_path($2);
@outputDirectory = get_absolute_path($3);
@resourceGroupName = $4;

msg("Using ffmpeg:  @ffmpegPath\nReading from:  @inputDirectory\nOutputting to: @outputDirectory\nResource Group: @resourceGroupName");

proc _processFile(@subdirectory, @file, @folder, @outputDirectory, @resourceGroupName, @ffmpegPath) {
	msg(color('LIGHT_PURPLE')."Processing @file");
	@outputFilename = replace(to_lower(@file), ' ', '_');
	@outputFilename = reg_replace('(.*)\\.wav$', '$1', @outputFilename);
	@outputFilename = reg_replace('[^a-zA-Z0-9_]', '', @outputFilename);
	@outputFilename .= '.ogg';
	msg("Output filename: @outputFilename");

	@input = "@folder/@file";
	@output = "@outputDirectory/assets/@resourceGroupName/sounds/@subdirectory/@outputFilename";
	msg("input: @input, output: @output");
	delete_file(@output);
	shell("@ffmpegPath -i \"@input\" \"@output\"");
	@soundsjson = "@outputDirectory/assets/@resourceGroupName/sounds.json";
	@json = json_decode(read(@soundsjson));
	//msg(shell("@ffmpegPath -analyzeduration 999999999 -i \"@input\""));
	@stream = false;
	if(file_size(@output) < 1000000000) {
		// Not perfect, but good enough to determine if we ought to stream this or not.
		@stream = true;
	}

	@rawFile = reg_replace("(.*)\\.ogg", '$1', @outputFilename);

	// Read it like this because we want to keep any existing info in the json
	// except for a specific few fields.
	@topArray = array_get(@json, "@subdirectory.@rawFile", associative_array());
	@sounds = array_get(@topArray, 'sounds', array());
	@soundObject = array_get(@sounds, 0, associative_array());

	@soundObject['name'] = "@resourceGroupName:@subdirectory/@rawFile";
	@soundObject['stream'] = @stream;
	@sounds[0] = @soundObject;
	@topArray['sounds'] = @sounds;
	@json["@subdirectory.@rawFile"] = @topArray;

	write_file(@soundsjson, json_encode(@json), 'OVERWRITE');
}

proc _processDirectory(@folder, @topLevelFolder, @outputDirectory, @resourceGroupName, @ffmpegPath) {
	foreach(@file in list_files(@folder)) {
		if(is_dir(@folder.'/'.@file)) {
			msg("Processing directory @folder/@file")
			_processDirectory(@folder.'/'.@file, @topLevelFolder, @outputDirectory, @resourceGroupName, @ffmpegPath);
		} else {
			@subdirectory = '';
			if(@folder != @topLevelFolder) {
				if(string_ends_with(@folder, '/') || string_ends_with(@folder, '\\')) {
					@folder = @folder[..-1];
				}
				@subdirectory = reg_replace('.*[\\/](.*?)$', '$1', @folder);
			}
			_processFile(@subdirectory, @file, @folder, @outputDirectory, @resourceGroupName, @ffmpegPath);
		}
	}
}

_processDirectory(@inputDirectory, @inputDirectory, @outputDirectory, @resourceGroupName, @ffmpegPath);