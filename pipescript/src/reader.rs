use std::collections::HashMap;

use crate::ps_env::*;

pub fn source_to_instructions(buffer: String) -> (Vec<Vec<PSValue>>, HashMap<String, usize>, Vec<PSValue>) {
	let mut env = Vec::<PSValue>::new();

	// Convert the raw text into commands
	let mut variable_hash = HashMap::<String, usize>::new();
	let mut lines: Vec<Vec<PSValue>> = vec![ vec![PSValue::Instruction(PSInstructionSet::HashToken)] ]; // First instruction is always a comment
	for line in buffer.lines() {
		if !line.is_empty() {
			let line_commands: Vec<&str> = line
				.split(' ')
				.map(|segment| segment.trim())
				.collect();
			let mut commands = Vec::<PSValue>::new();
			let (first, args) = line_commands.split_at(1);

			commands.push(
				match *first.get(0).expect(PSError::error_message(PSError::MissingArgument)) {
					"set" => PSValue::Instruction(PSInstructionSet::Set),
					"unset" => PSValue::Instruction(PSInstructionSet::Unset),
					"is-defined" => PSValue::Instruction(PSInstructionSet::IsDefined),
					"string-literal" => PSValue::Instruction(PSInstructionSet::StringLiteral),
					"concat" => PSValue::Instruction(PSInstructionSet::Concat),
					"add" => PSValue::Instruction(PSInstructionSet::Add),
					"sub" => PSValue::Instruction(PSInstructionSet::Sub),
					"mul" => PSValue::Instruction(PSInstructionSet::Mul),
					"div" => PSValue::Instruction(PSInstructionSet::Div),
					"pow" => PSValue::Instruction(PSInstructionSet::Pow),
					"and" => PSValue::Instruction(PSInstructionSet::And),
					"or" => PSValue::Instruction(PSInstructionSet::Or),
					"lesser-than" => PSValue::Instruction(PSInstructionSet::LesserThan),
					"lesser-than-equals" => PSValue::Instruction(PSInstructionSet::LesserThanEquals),
					"greater-than" => PSValue::Instruction(PSInstructionSet::GreaterThan),
					"greater-than-equals" => PSValue::Instruction(PSInstructionSet::GreaterThanEquals),
					"equals" => PSValue::Instruction(PSInstructionSet::Equals),
					"not-equals" => PSValue::Instruction(PSInstructionSet::NotEquals),
					"print-no-ln" => PSValue::Instruction(PSInstructionSet::PrintNoLn),
					"print" => PSValue::Instruction(PSInstructionSet::Print),
					"debug-all" => PSValue::Instruction(PSInstructionSet::DebugAll),
					"debug-cmds" => PSValue::Instruction(PSInstructionSet::DebugCmds),
					"if" => PSValue::Instruction(PSInstructionSet::If),
					"if-not" => PSValue::Instruction(PSInstructionSet::IfNot),
					"goto" => PSValue::Instruction(PSInstructionSet::Goto),
					"label" => PSValue::Instruction(PSInstructionSet::Label),
					"return" => PSValue::Instruction(PSInstructionSet::Return),
					"call" => PSValue::Instruction(PSInstructionSet::Call),
					"function" => PSValue::Instruction(PSInstructionSet::Function),
					"danger!-add-line-pointer" => PSValue::Instruction(PSInstructionSet::DangerAddLinePointer),
					"danger!-to-float" => PSValue::Instruction(PSInstructionSet::DangerToFloat),
					"danger!-to-line-pointer" => PSValue::Instruction(PSInstructionSet::DangerToLinePointer),
					"end" => PSValue::Instruction(PSInstructionSet::End),
					"#" => PSValue::Instruction(PSInstructionSet::HashToken),
					"calc" => PSValue::Instruction(PSInstructionSet::Calc),
					"gd-call" => PSValue::Instruction(PSInstructionSet::GodotCall),
					_ => panic!("{}", PSError::error_message(PSError::InvalidCommand))
				}
			);

			if first[0] == "calc" {
				let (label, expression) = args.split_at(1);
				commands.push(string_to_ps_value(
					label.get(0).expect(PSError::error_message(PSError::MissingArgument)),
					&mut env,
					&mut variable_hash
				));
				commands.push(PSValue::String(expression.join(" ")));
			} else {
				for cmd in args.to_owned() {
					commands.push(string_to_ps_value(cmd, &mut env, &mut variable_hash));
				};
			};

			lines.push(commands);
		};
	}
	(lines, variable_hash, env)
}
