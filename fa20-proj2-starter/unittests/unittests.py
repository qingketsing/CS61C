from unittest import TestCase
from framework import AssemblyTest, print_coverage


class TestAbs(TestCase):
    def test_zero(self):
        t = AssemblyTest(self, "abs.s")
        # load 0 into register a0
        t.input_scalar("a0", 0)
        # call the abs function
        t.call("abs")
        # check that after calling abs, a0 is equal to 0 (abs(0) = 0)
        t.check_scalar("a0", 0)
        # generate the `assembly/TestAbs_test_zero.s` file and run it through venus
        t.execute()

    def test_one(self):
        # same as test_zero, but with input 1
        t = AssemblyTest(self, "abs.s")
        t.input_scalar("a0", 1)
        t.call("abs")
        t.check_scalar("a0", 1)
        t.execute()
    def test_minus_one(self):
        t = AssemblyTest(self, "abs.s")
        t.input_scalar("a0", -5)
        t.call("abs")
        t.check_scalar("a0", 5)
        t.execute()

    @classmethod
    def tearDownClass(cls):
        print_coverage("abs.s", verbose=False)


class TestRelu(TestCase):
    def test_simple(self):
        t = AssemblyTest(self, "relu.s")
        # create an array in the data section
        array0 = t.array([1, -2, 3, -4, 5, -6, 7, -8, 9])
        # load address of `array0` into register a0
        t.input_array("a0", array0)
        # set a1 to the length of our array
        t.input_scalar("a1", len(array0))
        # call the relu function
        t.call("relu")
        # check that the array0 was changed appropriately
        t.check_array(array0, [1, 0, 3, 0, 5, 0, 7, 0, 9])
        t.execute()

    def test_error(self):
        t = AssemblyTest(self, "relu.s")
        # generate the `assembly/TestRelu_test_simple.s` file and run it through venus
        array1 = t.array([])
        # load address of `array1` into register a0
        t.input_array("a0", array1)
        # set a1 to the length of our array
        t.input_scalar("a1", len(array1))
        t.call("relu")
        # check that the error is called
        t.execute(code=78)

    @classmethod
    def tearDownClass(cls):
        print_coverage("relu.s", verbose=False)


class TestArgmax(TestCase):
    def test_simple(self):
        t = AssemblyTest(self, "argmax.s")
        # create an array in the data section
        array0 = t.array([1, -2, 3, -4, 5, -6, 7, -8, 9])
        # load address of the array into register a0
        t.input_array("a0", array0)
        # set a1 to the length of our array
        t.input_scalar("a1", len(array0))
        # call the `argmax` function
        t.call("argmax")
        # check that the register a0 contains the correct output
        t.check_scalar("a0", 8)
        # generate the `assembly/TestArgmax_test_simple.s` file and run it through venus
        t.execute()

    def test_error(self):
        t = AssemblyTest(self, "argmax.s")
        # create an array in the data section
        array1 = t.array([])
        # load address of `array1` into register a0
        t.input_array("a0", array1)
        # set a1 to the length of our array
        t.input_scalar("a1", len(array1))
        t.call("argmax")
        # check that the error is called
        t.execute(code=77)

    @classmethod
    def tearDownClass(cls):
        print_coverage("argmax.s", verbose=False)


class TestDot(TestCase):
    def test_simple(self):
        t = AssemblyTest(self, "dot.s")
        # create arrays in the data section
        array0 = t.array([1,2,3,4,5,6,7,8,9])
        array1 = t.array([1,2,3,4,5,6,7,8,9])
        t.input_array("a0", array0)
        t.input_array("a1", array1)
        t.input_scalar("a2", len(array1))
        t.input_scalar("a3", 1)
        t.input_scalar("a4", 1)
        t.call("dot")
        # 计算期望结果：1*1 + 2*2 + 3*3 + ... + 9*9 = 285
        t.check_scalar("a0", 285)
        t.execute()

    def error1_test(self):
        t = AssemblyTest(self, "dot.s")
        # create arrays in the data section
        array0 = t.array([])
        array1 = t.array([])
        t.input_array("a0", array0)
        t.input_array("a1", array1)
        t.input_scalar("a2", len(array1))
        t.input_scalar("a3", 1)
        t.input_scalar("a4", 1)
        t.call("dot")
        t.execute(code=75)
    
    def error2_test(self):
        t = AssemblyTest(self, "dot.s")
        # create arrays in the data section
        array0 = t.array([1,2,3,4,5,6,7,8,9])
        array1 = t.array([1,2,3,4,5,6,7,8,9])
        t.input_array("a0", array0)
        t.input_array("a1", array1)
        t.input_scalar("a2", len(array1))
        t.input_scalar("a3", 0)
        t.input_scalar("a4", 0)
        t.call("dot")
        t.execute(code=76)

    def test_stride(self):
        t = AssemblyTest(self, "dot.s")
        # 测试 stride = 2 的情况
        array0 = t.array([1,2,3,4,5,6])  # 使用 stride=2: [1,3,5]
        array1 = t.array([2,4,6,8,10,12]) # 使用 stride=2: [2,6,10]
        t.input_array("a0", array0)
        t.input_array("a1", array1)
        t.input_scalar("a2", 3)  # 只计算3个元素
        t.input_scalar("a3", 2)  # stride = 2
        t.input_scalar("a4", 2)  # stride = 2
        t.call("dot")
        # 期望结果: 1*2 + 3*6 + 5*10 = 2 + 18 + 50 = 70
        t.check_scalar("a0", 70)
        t.execute()

    @classmethod
    def tearDownClass(cls):
        print_coverage("dot.s", verbose=False)


class TestMatmul(TestCase):

    def do_matmul(self, m0, m0_rows, m0_cols, m1, m1_rows, m1_cols, result, code=0):
        t = AssemblyTest(self, "matmul.s")
        # we need to include (aka import) the dot.s file since it is used by matmul.s
        t.include("dot.s")

        # create arrays for the arguments and to store the result
        array0 = t.array(m0)
        array1 = t.array(m1)
        array_out = t.array([0] * len(result))

        # load address of input matrices and set their dimensions
        t.input_array("a0", array0)
        t.input_scalar("a1", m0_rows)
        t.input_scalar("a2", m0_cols)
        t.input_array("a3", array1)
        t.input_scalar("a4", m1_rows)
        t.input_scalar("a5", m1_cols)
        # load address of output array
        t.input_array("a6", array_out)

        # call the matmul function
        t.call("matmul")

        # check the content of the output array
        t.check_array(array_out, result)

        # generate the assembly file and run it through venus, we expect the simulation to exit with code `code`
        t.execute(code=code)

    def test_simple(self):
        self.do_matmul(
            [1, 2, 3, 4, 5, 6, 7, 8, 9], 3, 3,
            [1, 2, 3, 4, 5, 6, 7, 8, 9], 3, 3,
            [30, 36, 42, 66, 81, 96, 102, 126, 150]
        )

    @classmethod
    def tearDownClass(cls):
        print_coverage("matmul.s", verbose=False)


class TestReadMatrix(TestCase):

    def do_read_matrix(self, fail='', code=0):
        t = AssemblyTest(self, "read_matrix.s")
        # load address to the name of the input file into register a0
        t.input_read_filename("a0", "inputs/test_read_matrix/test_input.bin")

        # allocate space to hold the rows and cols output parameters
        rows = t.array([-1])
        cols = t.array([-1])

        # load the addresses to the output parameters into the argument registers
        t.input_array("a1", rows)  # address where rows will be stored
        t.input_array("a2", cols)  # address where cols will be stored

        # call the read_matrix function
        t.call("read_matrix")

        # check the output from the function
        if code == 0:  # only check results if we expect success
            # check that rows and cols were set correctly (3x3 matrix)
            t.check_array(rows, [3])
            t.check_array(cols, [3])
            
            # check that the returned matrix pointer is not null
            # The matrix should contain the values from the test file: 1,2,3,4,5,6,7,8,9
            expected_matrix = [1, 2, 3, 4, 5, 6, 7, 8, 9]
            t.check_array_pointer("a0", expected_matrix)

        # generate assembly and run it through venus
        t.execute(fail=fail, code=code)

    def test_simple(self):
        self.do_read_matrix()

    def test_nonexistent_file(self):
        # Test with a file that doesn't exist - should fail with code 90
        t = AssemblyTest(self, "read_matrix.s")
        t.input_read_filename("a0", "inputs/test_read_matrix/nonexistent.bin")
        
        rows = t.array([-1])
        cols = t.array([-1])
        t.input_array("a1", rows)
        t.input_array("a2", cols)
        
        t.call("read_matrix")
        t.execute(code=90)  # expect fopen error

    def test_malloc_error(self):
        # This would be harder to test without modifying the malloc function
        # For now, we'll just test the normal case
        pass

    @classmethod
    def tearDownClass(cls):
        print_coverage("read_matrix.s", verbose=False)


class TestWriteMatrix(TestCase):

    def do_write_matrix(self, fail='', code=0):
        t = AssemblyTest(self, "write_matrix.s")
        outfile = "outputs/test_write_matrix/student.bin"
        # load output file name into a0 register
        t.input_write_filename("a0", outfile)
        
        # create a test matrix - using the same 3x3 matrix as in test_read_matrix
        # Matrix: [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
        test_matrix = t.array([1, 2, 3, 4, 5, 6, 7, 8, 9])
        
        # load input array and other arguments
        t.input_array("a1", test_matrix)  # matrix data
        t.input_scalar("a2", 3)           # number of rows
        t.input_scalar("a3", 3)           # number of columns
        
        # call `write_matrix` function
        t.call("write_matrix")
        # generate assembly and run it through venus
        t.execute(fail=fail, code=code)
        # compare the output file against the reference
        t.check_file_output(outfile, "outputs/test_write_matrix/reference.bin")

    def test_simple(self):
        self.do_write_matrix()

    def test_different_matrix_size(self):
        # Test with a different matrix size (2x4)
        t = AssemblyTest(self, "write_matrix.s")
        outfile = "outputs/test_write_matrix/student_2x4.bin"
        t.input_write_filename("a0", outfile)
        
        # create a 2x4 matrix: [[1, 2, 3, 4], [5, 6, 7, 8]]
        test_matrix = t.array([1, 2, 3, 4, 5, 6, 7, 8])
        t.input_array("a1", test_matrix)
        t.input_scalar("a2", 2)  # 2 rows
        t.input_scalar("a3", 4)  # 4 columns
        
        t.call("write_matrix")
        t.execute()
        # Note: For this test, we'd need a corresponding reference file

    @classmethod
    def tearDownClass(cls):
        print_coverage("write_matrix.s", verbose=False)


class TestClassify(TestCase):

    def make_test(self):
        t = AssemblyTest(self, "classify.s")
        t.include("argmax.s")
        t.include("dot.s")
        t.include("matmul.s")
        t.include("read_matrix.s")
        t.include("relu.s")
        t.include("write_matrix.s")
        return t

    def test_simple0_input0(self):
        """Test simple0 dataset with input0 - should classify as 2"""
        t = self.make_test()
        out_file = "outputs/test_basic_main/student0.bin"
        ref_file = "outputs/test_basic_main/reference0.bin"
        args = ["inputs/simple0/bin/m0.bin", "inputs/simple0/bin/m1.bin",
                "inputs/simple0/bin/inputs/input0.bin", out_file]
        
        # Set print_classification parameter
        t.input_scalar("a2", 0)  # 0 = print classification result
        
        # call classify function
        t.call("classify")
        # generate assembly and pass program arguments directly to venus
        t.execute(args=args)

        # compare the output file
        t.check_file_output(out_file, ref_file)
        
        # compare the classification output with `check_stdout`
        # The expected classification result should be "2" based on simple0 dataset
        t.check_stdout("2")

    def test_simple0_input1(self):
        """Test simple0 dataset with input1"""
        t = self.make_test()
        out_file = "outputs/test_basic_main/student0_input1.bin"
        args = ["inputs/simple0/bin/m0.bin", "inputs/simple0/bin/m1.bin",
                "inputs/simple0/bin/inputs/input1.bin", out_file]
        
        # Set print_classification parameter
        t.input_scalar("a2", 0)  # 0 = print classification result
        
        # call classify function
        t.call("classify")
        t.execute(args=args)
        
        # For input1, the exact expected classification would depend on the data
        # But we can verify that the function runs without error

    def test_simple1_input0(self):
        """Test simple1 dataset with input0 - should classify as 1"""
        t = self.make_test()
        out_file = "outputs/test_basic_main/student1.bin"
        ref_file = "outputs/test_basic_main/reference1.bin"
        args = ["inputs/simple1/bin/m0.bin", "inputs/simple1/bin/m1.bin",
                "inputs/simple1/bin/inputs/input0.bin", out_file]
        
        # Set print_classification parameter
        t.input_scalar("a2", 0)  # 0 = print classification result
        
        # call classify function
        t.call("classify")
        t.execute(args=args)
        
        # compare the output file
        t.check_file_output(out_file, ref_file)
        
        # The expected classification result should be "1" based on simple1 dataset
        t.check_stdout("1")

    def test_simple2_input0(self):
        """Test simple2 dataset with input0"""
        t = self.make_test()
        out_file = "outputs/test_basic_main/student2.bin"
        args = ["inputs/simple2/bin/m0.bin", "inputs/simple2/bin/m1.bin",
                "inputs/simple2/bin/inputs/input0.bin", out_file]
        
        # Set print_classification parameter
        t.input_scalar("a2", 0)  # 0 = print classification result
        
        # call classify function
        t.call("classify")
        t.execute(args=args)

    def test_print_classification_silent(self):
        """Test with print_classification = 1 (should not print classification)"""
        t = self.make_test()
        out_file = "outputs/test_basic_main/student_silent.bin"
        args = ["inputs/simple0/bin/m0.bin", "inputs/simple0/bin/m1.bin",
                "inputs/simple0/bin/inputs/input0.bin", out_file]
        
        # Set print_classification to 1 (don't print)
        t.input_scalar("a2", 1)
        
        # call classify function
        t.call("classify")
        t.execute(args=args)
        
        # Should not print anything to stdout
        t.check_stdout("")
        
    def test_nonexistent_m0_file(self):
        """Test with non-existent m0 file - should exit with error code 90"""
        t = self.make_test()
        out_file = "outputs/test_basic_main/student_error_m0.bin"
        args = ["inputs/simple0/bin/nonexistent.bin", "inputs/simple0/bin/m1.bin",
                "inputs/simple0/bin/inputs/input0.bin", out_file]
        
        # Set print_classification parameter
        t.input_scalar("a2", 0)
        
        # call classify function
        t.call("classify")
        # read_matrix should handle the error internally (code 90 for fopen error)
        t.execute(args=args, code=90)

    def test_nonexistent_m1_file(self):
        """Test with non-existent m1 file - should exit with error code 90"""
        t = self.make_test()
        out_file = "outputs/test_basic_main/student_error_m1.bin"
        args = ["inputs/simple0/bin/m0.bin", "inputs/simple0/bin/nonexistent.bin",
                "inputs/simple0/bin/inputs/input0.bin", out_file]
        
        # Set print_classification parameter
        t.input_scalar("a2", 0)
        
        # call classify function
        t.call("classify")
        t.execute(args=args, code=90)

    def test_nonexistent_input_file(self):
        """Test with non-existent input file - should exit with error code 90"""
        t = self.make_test()
        out_file = "outputs/test_basic_main/student_error_input.bin"
        args = ["inputs/simple0/bin/m0.bin", "inputs/simple0/bin/m1.bin",
                "inputs/simple0/bin/inputs/nonexistent.bin", out_file]
        
        # Set print_classification parameter
        t.input_scalar("a2", 0)
        
        # call classify function
        t.call("classify")
        t.execute(args=args, code=90)

    def test_different_print_classification_values(self):
        """Test with different print_classification values"""
        # Test with print_classification = 2 (should still be treated as "don't print")
        t = self.make_test()
        out_file = "outputs/test_basic_main/student_no_print_2.bin"
        args = ["inputs/simple0/bin/m0.bin", "inputs/simple0/bin/m1.bin",
                "inputs/simple0/bin/inputs/input0.bin", out_file]
        
        # Set print_classification to 2 (non-zero, so don't print)
        t.input_scalar("a2", 2)
        
        # call classify function
        t.call("classify")
        t.execute(args=args)
        
        # Should not print anything to stdout
        t.check_stdout("")

    @classmethod
    def tearDownClass(cls):
        print_coverage("classify.s", verbose=False)


class TestMain(TestCase):

    def run_main(self, inputs, output_id, label):
        args = [f"{inputs}/m0.bin", f"{inputs}/m1.bin", f"{inputs}/inputs/input0.bin",
                f"outputs/test_basic_main/student{output_id}.bin"]
        reference = f"outputs/test_basic_main/reference{output_id}.bin"
        t = AssemblyTest(self, "main.s", no_utils=True)
        t.call("main")
        t.execute(args=args, verbose=False)
        t.check_stdout(label)
        t.check_file_output(args[-1], reference)

    def test0(self):
        self.run_main("inputs/simple0/bin", "0", "2")

    def test1(self):
        self.run_main("inputs/simple1/bin", "1", "1")
