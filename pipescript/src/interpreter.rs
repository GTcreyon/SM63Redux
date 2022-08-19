
use crate::ps_env::*;
use gdnative::prelude::{godot_print, OwnedToVariant, Variant, FromVariant, Vector2};

pub fn execute_commands<'a>(lines: &'a mut Vec<Vec<PSValue>>, env: &mut Vec<PSValue>) {
	let line_count = lines.len();
	let mut line_idx = 0;
	while line_idx < line_count {
		let line = lines.get(line_idx).unwrap(); // This should always be valid
		let instruction = line.first().unwrap().expect_instruction(); // So should this
		line_idx += 1; // KEEP IN MIND! We iterate AT THE START NOT AT THE END!

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
				set_variable(&line[1], line[2].to_owned(), env);
			},
			PSInstructionSet::Concat => {
				let a = get_variable(&line[2], env).expect_string();
				let b = get_variable(&line[3], env).expect_string();
				set_variable(&line[1], PSValue::String(a + b.as_str()), env);
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
					gdnative::log::print(get_variable(arg, env).to_string());
				}
			},
			PSInstructionSet::Print => {
				if line.len() < 2 { panic!("{}", PSError::error_message(PSError::MissingArgument)) }
				for arg in line.split_at(1).1 {
					godot_print!("{} ", get_variable(arg, env).to_string());
				}
			},
			// Debug library, useful for figuring out the current scope & instruction set.
			PSInstructionSet::DebugAll => {
				godot_print!("--- ALL VARS ---");
				for (key, value) in env.into_iter().enumerate() {
					godot_print!(" {}: {} ({})", key, value.to_string(), value.get_type_as_text());
				}
				godot_print!("--- -------- ---");
			}
			PSInstructionSet::DebugCmds => {
				godot_print!("--- PRINT CMDS ---");
				for idx in 0..lines.len() {
					let mut print_msg = format!(" {}: ", idx);
					for str in lines.get(idx).unwrap() {
						print_msg += str.to_string().as_str();
						print_msg += " ";
					};
					godot_print!("{}", print_msg);
				};
				godot_print!("--- ---------- ---");
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
			// Godot object handler
			PSInstructionSet::GodotCall => {
				let object = unsafe { get_variable(&line[1], env).expect_godot_object_ref().assume_safe() };
				let func_name = get_variable(&line[2], env).expect_string();
				let args = line.split_at(3).1.iter().map(|v| 
					match v {
						PSValue::VarIndex(_) => get_variable(&v, env).owned_to_variant(),
						_ => v.owned_to_variant()
					}
				).collect::<Vec<Variant>>();
				unsafe { object.call(func_name, &args); };
			},
			PSInstructionSet::GodotCallReturns => {
				let object = unsafe { get_variable(&line[2], env).expect_godot_object_ref().assume_safe() };
				let func_name = get_variable(&line[3], env).expect_string();
				let args = line.split_at(4).1.iter().map(|v| 
					match v {
						PSValue::VarIndex(_) => get_variable(&v, env).owned_to_variant(),
						_ => v.owned_to_variant()
					}
				).collect::<Vec<Variant>>();
				let return_value = unsafe { object.call(func_name, &args) };
				match PSValue::from_variant(&return_value) {
					Ok(val) => set_variable(&line[1], val, env),
					Err(err) => panic!("{}", err.to_string())
				}
			},
			// Godot Vector2 Library
			PSInstructionSet::GodotVector2Create => {
				let x = get_variable(&line[2], env).expect_number();
				let y = get_variable(&line[3], env).expect_number();
				set_variable(&line[1], PSValue::GodotVector2(Vector2::new(x, y)), env);
			},
			PSInstructionSet::GodotVector2GetAxis => {
				let vector = get_variable(&line[2], env).expect_vector2();
				let axis = get_variable(&line[3], env).expect_string();
				set_variable(&line[1], PSValue::Number( if axis == "x" {
					vector.x
				} else if axis == "y" {
					vector.y
				} else {
					panic!("{}", PSError::error_message(PSError::InvalidVector2Axis));
				} ), env);
			},
			PSInstructionSet::GodotVector2SetAxis => {
				let number = get_variable(&line[1], env).expect_number();
				let axis = get_variable(&line[3], env).expect_string();
				let mut vector = get_variable(&line[2], env).expect_vector2();
				if axis == "x" {
					vector.x = number;
				} else if axis == "y" {
					vector.y = number;
				} else {
					panic!("{}", PSError::error_message(PSError::InvalidVector2Axis));
				}
				// Since .expect_* clone the values, we have to re-assign them
				set_variable(&line[2], PSValue::GodotVector2(vector), env);
			}
			// Exit
			PSInstructionSet::Exit => {
				break;
			},
			// Instructions which should do nothing.
			PSInstructionSet::End => (),
			PSInstructionSet::Calc => (),
			PSInstructionSet::HashToken => ()
		};
	}
}
