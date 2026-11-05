
# Custom PDN configuration for IHP SG13G2 SRAM macro integration
#
# Connect the SRAM macro power pins on Metal4 to the TopMetal1
# power stripes. This is based on the IHP SG13G2 SRAM reference design.

source $::env(SCRIPTS_DIR)/openroad/common/set_global_connections.tcl
set_global_connections

set secondary []
foreach vdd $::env(VDD_NETS) gnd $::env(GND_NETS) {
    if { $vdd != $::env(VDD_NET)} {
        lappend secondary $vdd

        set db_net [[ord::get_db_block] findNet $vdd]
        if {$db_net == "NULL"} {
            set net [odb::dbNet_create [ord::get_db_block] $vdd]
            $net setSpecial
            $net setSigType "POWER"
        }
    }

    if { $gnd != $::env(GND_NET)} {
        lappend secondary $gnd

        set db_net [[ord::get_db_block] findNet $gnd]
        if {$db_net == "NULL"} {
            set net [odb::dbNet_create [ord::get_db_block] $gnd]
            $net setSpecial
            $net setSigType "GROUND"
        }
    }
}

set_voltage_domain -name CORE -power $::env(VDD_NET) -ground $::env(GND_NET) \
    -secondary_power $secondary

# Standard-cell power grid
define_pdn_grid \
    -name stdcell_grid \
    -starts_with POWER \
    -voltage_domain CORE \
    -pins $::env(PDN_VERTICAL_LAYER)

add_pdn_stripe \
    -grid stdcell_grid \
    -layer $::env(PDN_VERTICAL_LAYER) \
    -width $::env(PDN_VWIDTH) \
    -pitch $::env(PDN_VPITCH) \
    -offset $::env(PDN_VOFFSET) \
    -spacing $::env(PDN_VSPACING) \
    -starts_with POWER -extend_to_core_ring

# Standard-cell rails
if { $::env(PDN_ENABLE_RAILS) == 1 } {
    add_pdn_stripe \
        -grid stdcell_grid \
        -layer $::env(PDN_RAIL_LAYER) \
        -width $::env(PDN_RAIL_WIDTH) \
        -followpins

    add_pdn_connect \
        -grid stdcell_grid \
        -layers "$::env(PDN_RAIL_LAYER) $::env(PDN_VERTICAL_LAYER)"
}

# SRAM macro power grid
# The SRAM power pins are on Metal4.
# Metal5 stripes bridge the SRAM pins to the chip-level TopMetal1 grid.

define_pdn_grid \
    -macro \
    -instances "cpu.data_ram" \
    -name sram_grid \
    -starts_with POWER

# Dedicated Metal5 power and ground stripes over the SRAM.
add_pdn_stripe \
    -grid sram_grid \
    -layer Metal5 \
    -width 1.2 \
    -pitch 11.24 \
    -offset 2.81 \
    -spacing 2.81 \
    -starts_with POWER

# Connect SRAM power pins to Metal5.
add_pdn_connect \
    -grid sram_grid \
    -layers "Metal4 Metal5"

# Connect Metal5 to the chip-level power grid.
add_pdn_connect \
    -grid sram_grid \
    -layers "Metal5 $::env(PDN_VERTICAL_LAYER)"
