from setuptools import setup
from setuptools_rust import Binding, RustExtension

setup(
    name="pyo3-test",
    version="0.1.0",
    rust_extensions=[RustExtension("pyo3_test", binding=Binding.PyO3)],
    zip_safe=False,
)
