function main(insn_bits) : bits(32) -> unit = {
    let insn = if isRVC(insn_bits[15..0]) then {
        encdec_compressed(insn_bits[15..0])
    } else {
        encdec(insn_bits)
    };

    let res = execute(insn);
}
