package embed

import "core:fmt"
import "core:os"
import fp "core:path/filepath"
import s "core:strings"


INPUT_PATH :: "assets/"
OUTPUT_PATH :: "src/simulation/assets/"

DATA_WIDTH :: 15

file_as_code := proc(file_path: string, file_data: []byte) -> string {
	file_ext := fp.ext(file_path)
	file_base_name := fp.base(file_path)
	file_name, _ := s.substring_to(file_base_name, s.index(file_base_name, file_ext))
	file_name_upper := s.to_upper(file_name)
	file_size := len(file_data)

	builder := s.builder_make()

	fmt.sbprintfln(&builder, "package assets\n")
	fmt.sbprintfln(&builder, "%v_PATH :: `%v`", file_name_upper, file_path)
	fmt.sbprintfln(&builder, "%v_EXT :: \"%v\"", file_name_upper, file_ext)
	fmt.sbprintfln(&builder, "%v_SIZE :: %v", file_name_upper, file_size)
	fmt.sbprintfln(&builder, "@(rodata)")
	fmt.sbprintfln(&builder, "%v_DATA := [%v]byte{{", file_name_upper, file_size)

	for b, i in file_data {
		if i % DATA_WIDTH == 0 {
			fmt.sbprintf(&builder, "\t")
		}
		fmt.sbprintf(&builder, "%#02X, ", b)

		if i % DATA_WIDTH == (DATA_WIDTH - 1) {
			fmt.sbprintf(&builder, "\n")
		}
	}

	if len(file_data) % DATA_WIDTH != 0 {
		fmt.sbprintfln(&builder, "")
	}

	fmt.sbprintfln(&builder, "}}")
	fmt.sbprintfln(&builder, "%v_PTR := raw_data(&%v_DATA)", file_name_upper, file_name_upper)

	return s.to_string(builder)
}

export_file_as_code :: proc(input_path, output_path: string) {
	input_data, input_err := os.read_entire_file_from_path(input_path, context.allocator)
	if input_err != os.ERROR_NONE {
		msg := os.error_string(input_err)
		fmt.eprintfln("Could not read file %s: %s", input_path, msg)
		return
	}

	input_path, _ := os.clean_path(input_path, context.allocator)

	code := file_as_code(input_path, input_data)

	output, output_create_file_err := os.create(output_path)
	if output_create_file_err != os.ERROR_NONE {
		msg := os.error_string(output_create_file_err)
		fmt.eprintfln("Could not create output file %s: %s", output_path, msg)
		return
	}

	output_write_len, output_write_err := os.write_string(output, code)
	if output_write_err != os.ERROR_NONE {
		msg := os.error_string(output_write_err)
		fmt.eprintfln("Could not write file %s: %s", output_path, msg)
		return
	} else if output_write_len != len(code) {
		fmt.eprintfln("Did not write entire file %v/%v bytes written", output_write_len, len(code))
	}
}

export_dir_as_code :: proc(input_dir, output_dir: string) {
	walker := os.walker_create(input_dir)
	defer os.walker_destroy(&walker)

	output_create_dir_err := os.make_directory_all(output_dir)
	if output_create_dir_err != os.ERROR_NONE {
		msg := os.error_string(output_create_dir_err)
		fmt.eprintfln("Could not create output directory %s: %s", fp.dir(output_dir), msg)
		return
	}

	for info in os.walker_walk(&walker) {
		if path, err := os.walker_error(&walker); err != nil {
			msg := os.error_string(err)
			fmt.eprintfln("Failed to walk %s: %s", path, msg)
			continue
		}

		input_file_name, _ := s.substring_to(info.name, s.index(info.name, fp.ext(info.name)))
		output_file, _ := os.join_filename(input_file_name, "odin", context.allocator)
		output_path, _ := os.join_path({output_dir, output_file}, context.allocator)
		export_file_as_code(info.fullpath, output_path)
	}


}

main :: proc() {
	export_dir_as_code(INPUT_PATH, OUTPUT_PATH)
}
