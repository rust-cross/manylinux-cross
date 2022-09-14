#[cfg(feature = "test-cmake")]
use {libz_sys::zlibVersion, std::ffi::CStr};

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
    #[cfg(feature = "test-cmake")]
    {
        let ver = unsafe { zlibVersion() };
        let ver_cstr = unsafe { CStr::from_ptr(ver) };
        let version = ver_cstr.to_str().unwrap();
        assert!(!version.is_empty());
    }

    m.add_class::<DummyClass>()?;
    m.add("fourtytwo", 42)?;

    Ok(())
}
