set num_steps         250          ;# number of PSEN pulses to issue (250 * 17.86 ps =~ 4.4 ns)
set samples_per_step  16           ;# raw reads captured at each phase step
set psdone_timeout_ms 200          ;# max ms to wait for PSDONE per step
set settle_us         2            ;# extra time after PSDONE before sampling
set tdc_bits          128          ;# width of tdc_data_out (LEVEL_COUNT*4)
set output_file       "tdc_data.csv"



proc hex_nibble_to_bin {c} {
    switch -- [string tolower $c] {
        0 {return 0000} 1 {return 0001} 2 {return 0010} 3 {return 0011}
        4 {return 0100} 5 {return 0101} 6 {return 0110} 7 {return 0111}
        8 {return 1000} 9 {return 1001} a {return 1010} b {return 1011}
        c {return 1100} d {return 1101} e {return 1110} f {return 1111}
        default {return xxxx}
    }
}

# Normalize a hw_probe INPUT_VALUE (which may come back as "128'h1a2b..."
# or with leading zeros stripped) into a fixed-width, zero-padded hex
# string, plus the binary thermometer-code string.
proc format_tdc_value {raw width_bits} {
    set hex_val $raw
    regsub {^[0-9]+'h} $hex_val "" hex_val
    set hex_val [string trim $hex_val]
    if {$hex_val eq ""} { set hex_val "0" }

    set width_hex [expr {$width_bits / 4}]
    set pad [expr {$width_hex - [string length $hex_val]}]
    if {$pad > 0} {
        set hex_val "[string repeat 0 $pad]$hex_val"
    } elseif {$pad < 0} {
        set hex_val [string range $hex_val [expr {-$pad}] end]
    }

    set bin_val ""
    foreach c [split $hex_val ""] {
        append bin_val [hex_nibble_to_bin $c]
    }

    set ones [regsub -all {0} $bin_val "" tmp]
    set popcount [string length $tmp]

    return [list $hex_val $bin_val $popcount]
}



puts "================================================="
puts "Start TDC testing..."
puts "================================================="

set hw_devices [get_hw_devices -quiet *xc7z010*]
if {[llength $hw_devices] == 0} {
    puts "ERROR: Zynq (xc7z010) wasn't detected."
    return
}
set target_device [lindex $hw_devices 0]
set vio_core [get_hw_vios -of_objects $target_device]

if {[llength $vio_core] == 0} {
    puts "ERROR: VIO not found on device $target_device. Check if bitstream is loaded."
    return
}

set port_tdc_data [get_hw_probes -of_objects $vio_core *tdc_data_out]  ;# Input: TDC data
set port_psdone   [get_hw_probes -of_objects $vio_core *psdone]        ;# Input: flag shift done
set port_psen     [get_hw_probes -of_objects $vio_core *vio_psen]      ;# Output: activation shift pulse
set port_psincdec [get_hw_probes -of_objects $vio_core *vio_psincdec]  ;# Output: shift direction (1 = incr)

set fp [open $output_file w]
puts $fp "Step,Sample,Phase_step_ps,TDC_Hex,TDC_Bin,PopCount"

set_property OUTPUT_VALUE 1 $port_psincdec
set_property OUTPUT_VALUE 0 $port_psen
commit_hw_vio $vio_core
puts "VIO setup finished. Start $num_steps steps x $samples_per_step samples..."

set fine_step_ps 17.86
set aborted 0

for {set i 0} {$i < $num_steps} {incr i} {

    # issue one phase-shift pulse
    set_property OUTPUT_VALUE 1 $port_psen
    commit_hw_vio $vio_core
    set_property OUTPUT_VALUE 0 $port_psen
    commit_hw_vio $vio_core

    # wait for PSDONE
    set is_done 0
    set waited_ms 0
    while {$is_done == 0 && $waited_ms < $psdone_timeout_ms} {
        refresh_hw_vio $vio_core
        set is_done [get_property INPUT_VALUE $port_psdone]
        if {$is_done == 0} {
            after 1
            incr waited_ms
        }
    }

    if {$is_done == 0} {
        puts "WARNING: PSDONE timeout at step $i. Aborting script (check RTL PSEN one-shot / clock config)."
        set aborted 1
        break
    }

    # small settle margin after PSDONE before trusting the TDC output
    after [expr {$settle_us}] ;

    set phase_ps [expr {$i * $fine_step_ps}]

    for {set s 0} {$s < $samples_per_step} {incr s} {
        refresh_hw_vio $vio_core
        set raw_val [get_property INPUT_VALUE $port_tdc_data]
        lassign [format_tdc_value $raw_val $tdc_bits] hex_val bin_val popcount
        puts $fp "$i,$s,$phase_ps,$hex_val,$bin_val,$popcount"
    }

    if {$i % 25 == 0} {
        puts "Step $i \t| Phase ~$phase_ps ps \t| last sample: $hex_val (popcount=$popcount)"
        flush $fp
    }
}

close $fp
puts "================================================="
if {$aborted} {
    puts "Sweep ABORTED early at step $i due to PSDONE timeout."
} else {
    puts "Successfully finished! Collected $num_steps steps x $samples_per_step samples."
}
puts "File saved: $output_file"
puts "================================================="
