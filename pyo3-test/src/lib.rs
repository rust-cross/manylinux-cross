use std::ffi::CStr;

use libz_sys::zlibVersion;
use pyo3::prelude::*;

#[pyclass]
struct DummyClass {}

#[pymethods]
impl DummyClass {
    #[staticmethod]
    fn get_42() -> PyResult<usize> {
        Ok(42)
    }
}

#[pymodule]
fn pyo3_test(_py: Python, m: &PyModule) -> PyResult<()> {
    let ver = unsafe { zlibVersion() };
    let ver_cstr = unsafe { CStr::from_ptr(ver) };
    let version = ver_cstr.to_str().unwrap();
    assert!(!version.is_empty());

    m.add_class::<DummyClass>()?;
    m.add("fourtytwo", 42)?;

    Ok(())
}
