
use crate::ps_env::*;

pub fn execute_commands<'a>(lines: &'a mut Vec<Vec<PSValue>>, env: &mut Vec<PSValue>) {
	let line_count = lines.len();
	let mut line_idx = 0;
	while line_idx < line_count {
		let line = lines.get(line_idx).unwrap(); // This should always be valid
		let instruction = line.first().unwrap().expect_instruction(); // So should this
		line_idx += 1; // KEEP IN MIND! We iterate AT THE START NOT AT THE END!

		// println!("{}: {}", line_idx, instruction.as_ref());

		// Execute the current instruction
		match instruction {
			// Variable control
			PSInstructionSet::Set => {
				set_variable(&line[1], line[2].to_owned(), env);
			},
			PSInstructionSet::Unset => {
				if line.len() < 2 { panic!("{}", PSError::error_message(PSError::MissingArgument)) }
				for arg in line.split_at(1).1 {
				set_variable(arg, PSValue::None, env);
				}
			},
			PSInstructionSet::IsDefined => {
				set_variable(
					&line[1],
					PSValue::Number(if get_variable(&line[2], env).is_defined() { 1.0 } else { 0.0 }),
					env
				);
			},
			PSInstructionSet::StringLiteral => {
				// // To store empty strings, just provide a second argument
				// let mut literal_string = String::new();
				// for text in line.split_at(2).1 {
				// 	literal_string += text;
				// 	literal_string += " ";
				// };
				// literal_string.pop();
				// env.insert(
				// 	get_variable_name(commands, 1),
				// 	PSValue::String(literal_string)
				// );
			},
			PSInstructionSet::Concat => {
				// env.insert(
				// 	get_variable_name(commands, 1),
				// 	PSValue::String(
				// 		get_variable(commands, 2, env).to_string() + &get_variable(commands, 3, env).to_string()
				// 	)
				// );
			},
			// Maths operations
			PSInstructionSet::Add => {
				let x = get_variable(&line[2], env).expect_number();
				let y = get_variable(&line[3], env).expect_number();
				set_variable(&line[1], PSValue::Number(x + y), env);
			},
			PSInstructionSet::Sub => {
				let x = get_variable(&line[2], env).expect_number();
				let y = get_variable(&line[3], env).expect_number();
				set_variable(&line[1], PSValue::Number(x - y), env);
			},
			PSInstructionSet::Mul => {
				let x = get_variable(&line[2], env).expect_number();
				let y = get_variable(&line[3], env).expect_number();
				set_variable(&line[1], PSValue::Number(x * y), env);
			},
			PSInstructionSet::Div => {
				let x = get_variable(&line[2], env).expect_number();
				let y = get_variable(&line[3], env).expect_number();
				set_variable(&line[1], PSValue::Number(x / y), env);
			},
			PSInstructionSet::Pow => {
				let x = get_variable(&line[2], env).expect_number();
				let y = get_variable(&line[3], env).expect_number();
				set_variable(&line[1], PSValue::Number(x.powf(y)), env);
			},
			PSInstructionSet::And => {
				let x = get_variable(&line[2], env).expect_number();
				let y = get_variable(&line[3], env).expect_number();
				set_variable(&line[1], PSValue::Number(if x != 0.0 && y != 0.0 { 1.0 } else { 0.0 }), env);
			},
			PSInstructionSet::Or => {
				let x = get_variable(&line[2], env).expect_number();
				let y = get_variable(&line[3], env).expect_number();
				set_variable(&line[1], PSValue::Number(if x != 0.0 || y != 0.0 { 1.0 } else { 0.0 }), env);
			},
			PSInstructionSet::LesserThan => {
				let x = get_variable(&line[2], env).expect_number();
				let y = get_variable(&line[3], env).expect_number();
				set_variable(&line[1], PSValue::Number(if x < y { 1.0 } else { 0.0 }), env);
			},
			PSInstructionSet::LesserThanEquals => {
				let x = get_variable(&line[2], env).expect_number();
				let y = get_variable(&line[3], env).expect_number();
				set_variable(&line[1], PSValue::Number(if x <= y { 1.0 } else { 0.0 }), env);
			},
			PSInstructionSet::GreaterThan => {
				let x = get_variable(&line[2], env).expect_number();
				let y = get_variable(&line[3], env).expect_number();
				set_variable(&line[1], PSValue::Number(if x > y { 1.0 } else { 0.0 }), env);
			},
			PSInstructionSet::GreaterThanEquals => {
				let x = get_variable(&line[2], env).expect_number();
				let y = get_variable(&line[3], env).expect_number();
				set_variable(&line[1], PSValue::Number(if x >= y { 1.0 } else { 0.0 }), env);
			},
			PSInstructionSet::Equals => {
				let x = get_variable(&line[2], env).expect_number();
				let y = get_variable(&line[3], env).expect_number();
				set_variable(&line[1], PSValue::Number(if x == y { 1.0 } else { 0.0 }), env);
			},
			PSInstructionSet::NotEquals => {
				let x = get_variable(&line[2], env).expect_number();
				let y = get_variable(&line[3], env).expect_number();
				set_variable(&line[1], PSValue::Number(if x != y { 1.0 } else { 0.0 }), env);
			},
			// Print library, for all your console output needs.
			PSInstructionSet::PrintNoLn => {
				if line.len() < 2 { panic!("{}", PSError::error_message(PSError::MissingArgument)) }
				for arg in line.split_at(1).1 {
					print!("{} ", get_variable(arg, env).to_string());
				}
			},
			PSInstructionSet::Print => {
				if line.len() < 2 { panic!("{}", PSError::error_message(PSError::MissingArgument)) }
				for arg in line.split_at(1).1 {
					println!("{} ", get_variable(arg, env).to_string());
				}
			},
			// Debug library, useful for figuring out the current scope & instruction set.
			PSInstructionSet::DebugAll => {
				println!("--- ALL VARS ---");
				for (key, value) in env.into_iter().enumerate() {
					println!(" {}: {} ({})", key, value.to_string(), value.get_type_as_text());
				}
				println!("--- -------- ---");
			}
			PSInstructionSet::DebugCmds => {
				println!("--- PRINT CMDS ---");
				for idx in 0..lines.len() {
					print!(" {}: ", idx);
					for str in lines.get(idx).unwrap() {
						print!("{} ", str.to_string()); //TODO: fix this
					};
					println!("");
				};
				println!("--- ---------- ---");
			}
			// If statements
			PSInstructionSet::If => {
				if get_variable(&line[1], env).expect_number() == 0.0 {
					line_idx = get_variable(&line[2], env).expect_line();
				};
			},
			PSInstructionSet::IfNot => {
				if get_variable(&line[1], env).expect_number() != 0.0 {
					line_idx = get_variable(&line[2], env).expect_line();
				};
			},
			// Functions & goto
			PSInstructionSet::Goto => {
				line_idx = get_variable(&line[1], env).expect_line();
			},
			PSInstructionSet::Label => {
				// We sub 1 since we do +1 at the start
				set_variable(&line[1], PSValue::LinePointer(line_idx - 1), env);
			}
			PSInstructionSet::Return => {
				let function_idx = get_variable(&line[1], env).expect_line();
				line_idx = lines.get_mut(function_idx - 1)
					.expect(PSError::error_message(PSError::FunctionDoesNotExist))
					.pop()
					.expect(PSError::error_message(PSError::ReturnFromNoCaller))
					.expect_line();
			},
			PSInstructionSet::Call => {
				let origin_idx = line_idx;
				line_idx = get_variable(&line[1], env).expect_line();
				lines.get_mut(line_idx)
					.expect(PSError::error_message(PSError::FunctionDoesNotExist))
					.push(PSValue::LinePointer(origin_idx));
				line_idx += 1;
			},
			PSInstructionSet::Function => {
				set_variable(&line[1], PSValue::LinePointer(line_idx - 1), env);
				line_idx = get_variable(&line[2], env).expect_line();
			},
			// The danger! library, these functions should never be used. They're for type conversion and line pointer maths.
			PSInstructionSet::DangerAddLinePointer => {
				let x = get_variable(&line[2], env).expect_line();
				let y = get_variable(&line[3], env).expect_line();
				set_variable(&line[1], PSValue::LinePointer(x + y), env);
			},
			PSInstructionSet::DangerToFloat => {
				set_variable(
					&line[1],
					PSValue::Number(get_variable(&line[2], env).expect_line() as f32),
					env
				);
			},
			PSInstructionSet::DangerToLinePointer => {
				set_variable(
					&line[1],
					PSValue::LinePointer(get_variable(&line[2], env).expect_number() as usize),
					env
				);
			},
			// Instructions which should do nothing.
			PSInstructionSet::End => (),
			PSInstructionSet::Calc => (),
			PSInstructionSet::HashToken => ()
		};
	}
}
