
use std::collections::HashMap;
use gdnative::prelude::{Object, Ref, ToVariant, Variant, FromVariant, FromVariantError, Shared};
use strum_macros::AsRefStr;

#[derive(Clone, Copy, PartialEq, Eq, AsRefStr)]
pub enum PSInstructionSet {
	Set = 1,
	Unset = 2,
	IsDefined = 3,
	StringLiteral = 4,
	Concat = 5,
	Add = 6,
	Sub = 7,
	Mul = 8,
	Div = 9,
	Pow = 10,
	And = 11,
	Or = 12,
	LesserThan = 13,
	LesserThanEquals = 14,
	GreaterThan = 15,
	GreaterThanEquals = 16,
	Equals = 17,
	NotEquals = 18,
	PrintNoLn = 19,
	Print = 20,
	DebugAll = 21,
	DebugCmds = 22,
	If = 23,
	IfNot = 24,
	Goto = 25,
	Label = 26,
	Return = 27,
	Call = 28,
	Function = 29,
	DangerAddLinePointer = 30,
	DangerToFloat = 31,
	DangerToLinePointer = 32,
	End = 33,
	HashToken = 34,
	Calc = 35,
	GodotCall = 36,
	GodotCallReturns = 37
}

pub enum PSError {
	NotFound,
	WrongType,
	InvalidCommand,
	MissingArgument,
	UnfinishedIfStatement,
	UnfinishedFunctionStatement,
	NestedFunctionStatement,
	FunctionDoesNotExist,
	ReturnFromNoCaller,
	MalformattedVariable,
	InvalidOperator,
	MalformattedCalculation
}

// TODO: Give error messages line (& character information)
impl PSError {
	pub fn error_message<'a>(error: PSError) -> &'a str {
		match error {
			PSError::NotFound => "Variable does not exist.",
			PSError::WrongType => "Tried to use the wrong type.",
			PSError::InvalidCommand => "Encountered unknown command.",
			PSError::MissingArgument => "Missing required argument.",
			PSError::UnfinishedIfStatement => "Unfinished if-statement.",
			PSError::UnfinishedFunctionStatement => "Unfinished function-statement.",
			PSError::NestedFunctionStatement => "Nested functions are not allowed.",
			PSError::FunctionDoesNotExist => "Called function does not exist.",
			PSError::ReturnFromNoCaller => "Attempted to return from a function which hasn't been called.",
			PSError::MalformattedVariable => "Malformatted variable name and or number literal. The use of literal strings is prohibited. Input must be a valid variable name or number.",
			PSError::InvalidOperator => "Invalid operator found in calculation instruction.",
			PSError::MalformattedCalculation => "Malformatted calculation instruction (make sure the structure is OK)."
		}
	}
}

pub enum PSValue {
	String(String),
	Number(f32),
	LinePointer(usize),
	VarIndex(usize),
	Instruction(PSInstructionSet),
	GodotObject(Ref<Object>),
	None
}

impl FromVariant for PSValue {
    fn from_variant(variant: &Variant) -> Result<Self, gdnative::prelude::FromVariantError> {
		if variant.is_nil() { return Ok(PSValue::None); }
		if let Ok(v) = f32::from_variant(variant) { return Ok(PSValue::Number(v)); }
		if let Ok(v) = String::from_variant(variant) { return Ok(PSValue::String(v)); }
		if let Ok(v) = Ref::<Object, Shared>::from_variant(variant) { return Ok(PSValue::GodotObject(v)); }
		Err(FromVariantError::CannotCast { class: variant.to_string(), to: "PSValue" })
    }
}
 
impl ToVariant for PSValue {
    fn to_variant(&self) -> Variant {
        match self {
			PSValue::String(v) => v.to_variant(),
            PSValue::Number(v) => v.to_variant(),
            PSValue::LinePointer(v) => v.to_variant(),
            PSValue::VarIndex(_) => Variant::nil(), // Variable pointers cannot be exported
            PSValue::Instruction(_) => Variant::nil(), // Instructions cannot be exported
            PSValue::GodotObject(v) => v.to_variant(),
			PSValue::None => Variant::nil()
		}
    }
}

// Convert PSValue to string
impl From<&PSValue> for String {
	fn from(any: &PSValue) -> Self {
		match any {
			PSValue::Number(v) => v.to_string(),
			PSValue::String(v) => v.to_owned(),
			PSValue::LinePointer(v) => v.to_string(),
			PSValue::VarIndex(v) => v.to_string(),
			PSValue::Instruction(v) => v.as_ref().to_string(),
			PSValue::GodotObject(_) => String::from("ObjectRef#????"),
			PSValue::None => String::from("None")
		}
	}
}

impl ToString for PSValue {
	fn to_string(&self) -> String {
		String::from(self)
	}
}

// Make sure we can clone PSValues
impl Clone for PSValue {
	fn clone(&self) -> Self {
		match self {
			PSValue::Number(v) => PSValue::Number(v.to_owned()),
			PSValue::String(v) => PSValue::String(v.to_owned()),
			PSValue::LinePointer(v) => PSValue::LinePointer(v.to_owned()),
			PSValue::VarIndex(v) => PSValue::VarIndex(v.to_owned()),
			PSValue::Instruction(_) => PSValue::None, // Instruction sets are not duplicatable
			PSValue::GodotObject(_) => PSValue::None, // GodotObjects sets are not duplicatable
			PSValue::None => PSValue::None
		}
	}
}

impl PSValue {
	pub fn expect_number(&self) -> f32 {
		match self {
			PSValue::Number(val) => *val,
			_ => panic!("{} (got {}, expected Number): Value {}", PSError::error_message(PSError::WrongType), self.get_type_as_text(), String::from(self))
		}
	}

	pub fn expect_line(&self) -> usize {
		match self {
			PSValue::LinePointer(val) => *val,
			_ => panic!("{} (got {}, expected LinePointer): Value {}", PSError::error_message(PSError::WrongType), self.get_type_as_text(), String::from(self))
		}
	}

	pub fn expect_string(&self) -> String {
		match self {
			PSValue::String(val) => val.to_owned(),
			_ => panic!("{} (got {}, expected String): Value {}", PSError::error_message(PSError::WrongType), self.get_type_as_text(), String::from(self))
		}
	}

	// Note: these return pointers
	pub fn expect_var_index(&self) -> usize {
		match self {
			PSValue::VarIndex(val) => *val,
			_ => panic!("{} (got {}, expected VarIndex): Value {}", PSError::error_message(PSError::WrongType), self.get_type_as_text(), String::from(self))
		}
	}

	pub fn expect_instruction(&self) -> &PSInstructionSet {
		match self {
			PSValue::Instruction(val) => val,
			_ => panic!("{} (got {}, expected Instruction): Value {}", PSError::error_message(PSError::WrongType), self.get_type_as_text(), String::from(self))
		}
	}

	pub fn expect_godot_object_ref(&self) -> &Ref<Object> {
		match self {
			PSValue::GodotObject(val) => val,
			_ => panic!("{} (got {}, expected GodotObject): Value {}", PSError::error_message(PSError::WrongType), self.get_type_as_text(), String::from(self))
		}
	}

	pub fn is_defined(&self) -> bool {
		match self {
			PSValue::None => false,
			_ => true
		}
	}

	// You really shouldn't be using this.
	pub fn get_type_as_text(&self) -> &str {
		match self {
			PSValue::Number(_) => "Number",
			PSValue::String(_) => "String",
			PSValue::LinePointer(_) => "LinePointer",
			PSValue::VarIndex(_) => "VarIndex",
			PSValue::Instruction(_) => "Instruction",
			PSValue::GodotObject(_) => "GodotObject",
			PSValue::None => "None"
		}
	}
}

pub fn string_to_ps_value(cmd: &str, env: &mut Vec<PSValue>, variable_hash: &mut HashMap<String, usize>) -> PSValue {
	if cmd.ends_with(".U") {
		let mut result = cmd.to_owned();
		result.pop();
		result.pop();
		match result.parse::<usize>() {
			Ok(val) => PSValue::LinePointer(val),
			Err(_) => panic!("{}", PSError::error_message(PSError::MalformattedVariable)) 
		}
	} else if cmd.ends_with(".S") {
		let mut result = cmd.to_owned();
		result.pop();
		result.pop();
		PSValue::String(result)
	} else {
		match cmd.parse::<f32>() {
			// If we can convert to a number, do that
			Ok(val) => PSValue::Number(val),
			Err(_) => {
				if let Some(id) = variable_hash.get(cmd) {
					PSValue::VarIndex(*id)
				} else {
					let id = env.len();
					env.push(PSValue::None);
					variable_hash.insert(
						String::from(cmd),
						id
					);
					PSValue::VarIndex(id)
				}
			}
		}
	}
}

#[inline]
pub fn get_variable<'a>(value: &'a PSValue, env: &'a mut Vec<PSValue>) -> &'a PSValue {
	match value {
		PSValue::VarIndex(index) => &env.get(*index).expect(PSError::error_message(PSError::NotFound)),
		_ => value
	}
}

#[inline]
pub fn set_variable(key: &PSValue, value: PSValue, env: &mut Vec<PSValue>) {
	env[key.expect_var_index()] = value;
}
