
use std::collections::HashMap;

use gdnative::prelude::*;
use ps_env::PSValue;

mod preprocessor;
mod ps_env;
mod interpreter;
mod reader;

#[derive(NativeClass)]
#[inherit(Node)]
struct PipeScript {
	lines: Option<Vec<Vec<PSValue>>>,
	variable_hash: Option<HashMap<String, usize>>,
	env: Option<Vec<PSValue>>
}

#[methods]
impl PipeScript {
    fn new(_owner: &Node) -> Self {
        PipeScript { lines: None, variable_hash: None, env: None }
    }

	#[godot]
	fn set_object_variable(&mut self, #[base] _owner: &Node, key_gd: GodotString, obj_ref: Ref<Object>) {
		assert!(self.lines.is_some(), "Cannot insert variables, source isn't ready yet! Make sure to invoke `pipescript.interpret(source: String)` first.");
		let (lines, variable_hash, env) = (
			self.lines.as_mut().unwrap(),
			self.variable_hash.as_mut().unwrap(),
			self.env.as_mut().unwrap()
		);
		let key_str = key_gd.to_string();

		let key = if let Some(id) = variable_hash.get(&key_str) {
			PSValue::VarIndex(*id)
		} else {
			let id = env.len();
			env.push(PSValue::None);
			variable_hash.insert(
				key_str,
				id
			);
			PSValue::VarIndex(id)
		};

		ps_env::set_variable(&key, PSValue::GodotObject(obj_ref), env);
	}

	#[godot]
	fn i_take_a_node(&self, #[base] _owner: &Node, hello: Ref<Object>) {
		let node = unsafe { hello.assume_unique() };
		unsafe { node.call("test_call", &["some string idk".to_variant()]); }
	}

	#[godot]
	fn execute(&mut self, #[base] _owner: &Node) {
		assert!(self.lines.is_some(), "Cannot execute, source isn't ready yet! Make sure to invoke `pipescript.interpret(source: String)` first.");
		let (lines, variable_hash, env) = (
			self.lines.as_mut().unwrap(),
			self.variable_hash.as_mut().unwrap(),
			self.env.as_mut().unwrap()
		);
		// Pre-process
		preprocessor::preprocess(lines, env, variable_hash);
		// Execute the commands
		interpreter::execute_commands(lines, env);
	}

	#[godot]
	fn interpret(&mut self, #[base] _owner: &Node, source: GodotString) {
		let (lines, variable_hash, env) = reader::source_to_instructions(
			source.to_string()
		);

		self.lines = Some(lines);
		self.variable_hash = Some(variable_hash);
		self.env = Some(env);
	}

	#[godot]
    fn _ready(&self, #[base] _owner: &Node) {
        godot_print!("hello, world.")
    }
}

fn init(handle: InitHandle) {
    handle.add_class::<PipeScript>();
}

godot_init!(init);
