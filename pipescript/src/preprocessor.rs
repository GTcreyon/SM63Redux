
use std::{collections::HashMap};

use crate::ps_env::*;

fn statement_configure(lines: &mut Vec<Vec<PSValue>>) {
	let line_count = lines.len();
	let mut line_idx = 0;
	while line_idx < line_count {
		let commands = lines.get(line_idx).unwrap(); // This should always be valid
		let instruction = commands.first().unwrap().expect_instruction(); // So should this

		// If statement handler
		if instruction == &PSInstructionSet::If || instruction == &PSInstructionSet::IfNot {
			// Find the next same level endif
			let mut inner_idx = line_idx;
			let mut if_count = 0;
			while inner_idx < line_count {
				let inner_commands = lines.get(inner_idx).unwrap();
				let inner_instruction = inner_commands.first().unwrap().expect_instruction();
				match inner_instruction {
					// If there's an if, increase the level
					PSInstructionSet::If => {
						if_count += 1;
					},
					PSInstructionSet::IfNot => {
						if_count += 1;
					},
					// With an endif, lower the level
					PSInstructionSet::End => {
						// If we're at level 0, then exit
						if if_count == 0 {
							break;
						};
						if_count -= 1;
					},
					_ => ()
				};
				if if_count == 0 {
					break;
				};
				inner_idx += 1;
			};
			// If we have an endif index, then push it to the if statement
			if if_count == 0 {
				lines.get_mut(line_idx).unwrap().push(PSValue::LinePointer(inner_idx));
			} else {
				panic!("{}", PSError::error_message(PSError::UnfinishedIfStatement))
			}
		} else if instruction == &PSInstructionSet::Function {
			let mut inner_idx = line_idx;
			while inner_idx < line_count {
				let inner_commands = lines.get_mut(inner_idx).unwrap();
				let inner_instruction = inner_commands.first().unwrap().expect_instruction();
				if inner_instruction == &PSInstructionSet::Return {
					// We add one because we don't want to land on this instruction, but the one below
					// Make sure the 'return' instruction has a link back to the function
					inner_commands.push(PSValue::LinePointer(line_idx + 1));
					// Make sure the 'function' instruction has a link back to the return, this is so the interpreter skips the function
					lines.get_mut(line_idx).unwrap().push(PSValue::LinePointer(inner_idx + 1));
					break;
				} else if inner_instruction == &PSInstructionSet::Function {
					panic!("{}", PSError::error_message(PSError::NestedFunctionStatement));
				}
				inner_idx += 1;
			}
			if inner_idx < line_count {
				panic!("{}", PSError::error_message(PSError::UnfinishedFunctionStatement));
			}
		}
		
		line_idx += 1
	}
}

fn expression_unfolder(lines: &mut Vec<Vec<PSValue>>, env: &mut Vec<PSValue>, variable_hash: &mut HashMap<String, usize>) {
	let operators = [
		("^", 6 as usize, PSInstructionSet::Pow),
		("*", 5, PSInstructionSet::Mul),
		("/", 5, PSInstructionSet::Div),
		("+", 4, PSInstructionSet::Add),
		("-", 4, PSInstructionSet::Sub),
		("==", 3, PSInstructionSet::Equals),
		("!=", 3, PSInstructionSet::NotEquals),
		(">=", 3, PSInstructionSet::GreaterThanEquals),
		("<=", 3, PSInstructionSet::LesserThanEquals),
		(">", 3, PSInstructionSet::GreaterThan),
		("<", 3, PSInstructionSet::LesserThan),
		("&&", 2, PSInstructionSet::And),
		("||", 1, PSInstructionSet::Or)
	];

	enum OperatorIndex {
		Index(usize),
		Value(PSValue)
	}

	impl OperatorIndex {
		fn is_operator(&self) -> bool {
			match self {
				OperatorIndex::Index(_) => true,
				OperatorIndex::Value(_) => false
			}
		}

		fn expect_index(&self) -> usize {
			match self {
				OperatorIndex::Index(val) => val.to_owned(),
				_ => panic!("Cannot use expect_index() on non index OperatorIndex.")
			}
		}

		fn expect_ps_value(&self) -> PSValue {
			match self {
				OperatorIndex::Value(val) => val.to_owned(),
				_ => panic!("Cannot use expect_ps_value() on non value OperatorIndex.")
			}
		}
	}

	let mut line_count = lines.len();
	let mut line_idx = 0;
	while line_idx < line_count {
		let line = lines.get(line_idx).unwrap();
		let instruction = line.first().unwrap().expect_instruction();

		if instruction == &PSInstructionSet::Calc {
			let calc_result_name = line[1].expect_var_index();
			let mut expression = line[2].expect_string();

			// Seperate the expression into segments we can understand
			let mut segments = Vec::<OperatorIndex>::new();
			let mut buffer = String::new();
			while !expression.is_empty() {
				let mut skip_count = 0;
				let mut operator_idx = 0;
				for operator in operators {
					if expression.starts_with(operator.0) {
						// First empty the buffer
						if !buffer.is_empty() {
							segments.push(OperatorIndex::Value(
								string_to_ps_value(&buffer.trim(), env, variable_hash)
							));
							buffer = String::new();
						}
						// Now push our command
						segments.push(OperatorIndex::Index(operator_idx));
						skip_count = operator.0.len();
						break;
					};
					operator_idx += 1;
				};
				// Find out how much of the expression variable we should shave off
				let (chr, new_expr) = expression.split_at(if skip_count == 0 { 1 } else { skip_count });
				if skip_count == 0 {
					buffer += chr;
				};
				expression = new_expr.to_string();
			};
			// Make sure we use the final buffer
			if !buffer.is_empty() { segments.push(OperatorIndex::Value(string_to_ps_value(&buffer.trim(), env, variable_hash))) };

			let mut insert_command = |cmd| {
				lines.insert(line_idx, cmd);
				line_idx += 1;
				line_count += 1;
			};

			let mut created_variables = vec![ PSValue::Instruction(PSInstructionSet::Unset) ];

			while !segments.is_empty() {
				// Find the highest priority index
				let (mut b_idx, mut best_order) = (0 as usize, 0);
				for try_idx in 0..segments.len() {
					let segment = &segments[try_idx];
					if segment.is_operator() {
						let try_order = operators[segment.expect_index()].1;
						if try_order > best_order {
							b_idx = try_idx + 1;
							best_order = try_order;
						};
					};
				};

				// Panic! This is an impossible scenario in any well formatted string.
				if best_order == 0 {
					panic!("{}", PSError::error_message(PSError::InvalidOperator));
				};
				if b_idx < 2 || b_idx >= segments.len() {
					panic!("{}", PSError::error_message(PSError::MalformattedCalculation));
				}
				let a_idx = b_idx - 2;
				
				// Insert intermatiate variables and operation
				// let intermediate_var = get_unique_var();
				let intermediate_index = PSValue::VarIndex(env.len());
				insert_command(vec![
					PSValue::Instruction(
						operators[segments[b_idx - 1].expect_index()].2.to_owned()
					), // Operator
					if segments.len() < 4 {
						PSValue::VarIndex(calc_result_name) // If this is the last calculation, then use the result name
					} else {
						intermediate_index.to_owned() // Otherwise insert an intermediate variable
					},
					segments[a_idx].expect_ps_value(), // Operand A
					segments[b_idx].expect_ps_value() // Operand B
				]);
				
				// Make sure our segments array is well kept
				segments.remove(a_idx);
				segments.remove(a_idx);
				segments.remove(a_idx);
				// If the queue is empty, just don't bother
				if segments.len() > 0 {
					env.push(PSValue::None);
					created_variables.push(intermediate_index.to_owned());
					segments.insert(a_idx, OperatorIndex::Value(intermediate_index));
				};
			};

			// If we created intermediate variables, then unset them
			// There's no real need to do this besides for 'is-defined' to mark these variables as unset
			if created_variables.len() > 1 {
				insert_command(created_variables);
			}

			// At the end, make sure to remove our calc instruction
			lines.remove(line_idx);
			line_idx -= 1;
			line_count -= 1;
		};

		line_idx += 1;
	};
}

pub fn preprocess(lines: &mut Vec<Vec<PSValue>>, env: &mut Vec<PSValue>, variable_hash: &mut HashMap<String, usize>) {
	expression_unfolder(lines, env, variable_hash);
	statement_configure(lines);
}
