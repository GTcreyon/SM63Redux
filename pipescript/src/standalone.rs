use std::fs::File;
use std::io::{BufReader, Read};

mod ps_env;
mod interpreter;
mod reader;
mod preprocessor;

fn main() {
	let args: Vec<String> = std::env::args().collect();
	for arg in args.split_at(1).1 {
		let all = File::open(arg.as_str()).expect("Provided file does not exist.");
		let mut buffer = BufReader::new(all);
		let mut source = String::new();
		buffer.read_to_string(&mut source).expect("Invalid UTF-8.");
		
		let (mut lines, mut variable_hash, mut env) = reader::source_to_instructions(source);
	
		// Pre-process
		preprocessor::preprocess(&mut lines, &mut env, &mut variable_hash);
		// Execute the commands
		interpreter::execute_commands(&mut lines, &mut env);
	};
	if args.len() == 1 {
		println!("Please provide a file to run.");
	};
}


