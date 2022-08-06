
use gdnative::prelude::*;

mod preprocessor;
mod ps_env;
mod interpreter;
mod reader;

#[derive(NativeClass)]
#[inherit(Node)]
struct PipeScript;

#[methods]
impl PipeScript {
    fn new(_owner: &Node) -> Self {
        PipeScript
    }

	#[export]
	fn interpret(&self, _owner: &Node, source: GodotString) {
		godot_print!("Sup. I'm cool");

		let (mut lines, mut variable_hash, mut env) = reader::source_to_instructions(
			source.to_string()
		);
	
		// Pre-process
		preprocessor::preprocess(&mut lines, &mut env, &mut variable_hash);
		// Execute the commands
		interpreter::execute_commands(&mut lines, &mut env);

		godot_print!("Ended.");
	}

	#[export]
    fn _ready(&self, _owner: &Node) {
        godot_print!("hello, world.")
    }
}

fn init(handle: InitHandle) {
    handle.add_class::<PipeScript>();
}

godot_init!(init);
