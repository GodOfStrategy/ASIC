
# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, Timer


@cocotb.test()
async def test_tiny8_add_program(dut):

    dut._log.info("Starting Tiny8 processor test")

    # Start the clock
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # Configure inputs
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0

    # Apply reset
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 3)

    # Release reset
    dut.rst_n.value = 1

    # Allow the processor to execute its five instructions
    await ClockCycles(dut.clk, 35)
    await Timer(1, unit="ns")

    # Check the processor output
    output_value = int(dut.uo_out.value)
    program_counter = int(dut.uio_out.value)
    output_enable = int(dut.uio_oe.value)

    dut._log.info(f"CPU output: {output_value:#04x}")
    dut._log.info(f"Program counter: {program_counter:#04x}")

    assert output_value == 0x08, (
        f"Expected CPU output 0x08, got {output_value:#04x}"
    )

    assert program_counter == 0x05, (
        f"Expected program counter 0x05, got {program_counter:#04x}"
    )

    assert output_enable == 0xFF, (
        f"Expected all bidirectional pins to be outputs, got {output_enable:#04x}"
    )

    dut._log.info("Tiny8 processor test PASSED")
