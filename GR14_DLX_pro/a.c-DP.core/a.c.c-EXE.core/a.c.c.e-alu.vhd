LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.dlx_utils.ALL;

ENTITY ALU IS
	GENERIC
		(N : INTEGER := NbitLong);
	PORT
	(
		ALU_OPCODE            : IN ALU_MSG;
		DATA1, DATA2          : IN STD_LOGIC_VECTOR(0 TO N - 1);
		NEG, ZERO, CARRY, OVF : OUT STD_LOGIC;
		OUTALU                : OUT STD_LOGIC_VECTOR(0 TO N -1)
	);
END ALU;

ARCHITECTURE ARITH OF ALU IS
BEGIN
	PROCESS (ALU_OPCODE, DATA1, DATA2)
		VARIABLE TMP : STD_LOGIC_VECTOR(0 TO N); -- temporary result on N + 1 bits
	BEGIN
		-- default values
		NEG   <= '0';
		ZERO  <= '0';
		CARRY <= '0';
		OVF   <= '0';
		TMP := (OTHERS => '0');

		CASE ALU_OPCODE IS
			WHEN I_addui | I_jr | I_jalr | I_lbu | I_lhu | R_addu =>
				TMP := STD_LOGIC_VECTOR(RESIZE(UNSIGNED(DATA1),TMP'length) + RESIZE(UNSIGNED(DATA2),TMP'length));
				OVF <= ((DATA1(N-1) NOR DATA2(N-1)) AND TMP(N-1)) OR ((DATA1(N-1) AND DATA2(N-1)) AND NOT TMP(N-1));
				OUTALU <= STD_LOGIC_VECTOR(RESIZE(UNSIGNED(TMP),N));
			WHEN J_j | J_jal | I_addi | I_lb | I_lh | I_lw | I_sb | I_sh | I_sw | R_add =>
				TMP := STD_LOGIC_VECTOR(RESIZE(SIGNED(DATA1),TMP'length) + RESIZE(SIGNED(DATA2),TMP'length));
				NEG <= TMP(N - 1);
				OVF <= ((DATA1(N-1) NOR DATA2(N-1)) AND TMP(N-1)) OR ((DATA1(N-1) AND DATA2(N-1)) AND NOT TMP(N-1));
				OUTALU <= STD_LOGIC_VECTOR(RESIZE(UNSIGNED(TMP),N));
			WHEN I_beqz              =>
				IF (DATA2 = (DATA2'RANGE => '0')) THEN
					TMP := STD_LOGIC_VECTOR(RESIZE(SIGNED(DATA1),TMP'length) + RESIZE(SIGNED(DATA2),TMP'length));
					NEG <= TMP(N - 2);
					OVF <= ((DATA1(N-1) NOR DATA2(N-1)) AND TMP(N-1)) OR ((DATA1(N-1) AND DATA2(N-1)) AND NOT TMP(N-1));
					OUTALU <= STD_LOGIC_VECTOR(RESIZE(SIGNED(TMP),N));
				END IF;
			WHEN I_bnez               =>
				IF (DATA2 /= (DATA2'RANGE => '0')) THEN
					TMP := STD_LOGIC_VECTOR(RESIZE(SIGNED(DATA1),TMP'length) + RESIZE(SIGNED(DATA2),TMP'length));
					NEG <= TMP(N - 2);
					OVF <= ((DATA1(N-1) NOR DATA2(N-1)) AND TMP(N-1)) OR ((DATA1(N-1) AND DATA2(N-1)) AND NOT TMP(N-1));
					OUTALU <= STD_LOGIC_VECTOR(RESIZE(SIGNED(TMP),N));
				END IF;
			WHEN I_subui | R_subu =>
				TMP := STD_LOGIC_VECTOR(RESIZE(UNSIGNED(DATA1),TMP'length) - RESIZE(UNSIGNED(DATA2),TMP'length));
				OVF <= ((NOT DATA1(N-1) AND DATA2(N-1)) AND TMP(N-1)) OR (((DATA1(N-1) AND NOT DATA2(N-1)) AND NOT TMP(N-1)));
				OUTALU <= STD_LOGIC_VECTOR(RESIZE(UNSIGNED(TMP),N));
			WHEN I_subi | R_sub =>
				TMP := STD_LOGIC_VECTOR(RESIZE(UNSIGNED(DATA1),TMP'length) - RESIZE(UNSIGNED(DATA2),TMP'length));
				NEG <= TMP(N - 2);
				OVF <= ((NOT DATA1(N-1) AND DATA2(N-1)) AND TMP(N-1)) OR (((DATA1(N-1) AND NOT DATA2(N-1)) AND NOT TMP(N-1)));
				OUTALU <= STD_LOGIC_VECTOR(RESIZE(UNSIGNED(TMP),N));
			WHEN I_andi | R_and =>
				TMP(0 TO N - 1) := DATA1 AND DATA2;
				OUTALU <= TMP(0 to N-1);
			WHEN I_ori | R_or =>
				TMP(0 TO N - 1) := DATA1 OR DATA2;
				OUTALU <= TMP(0 to N-1);
			WHEN I_xori | R_xor =>
				TMP(0 TO N - 1) := DATA1 XOR DATA2;
				OUTALU <= TMP(0 to N-1);
			WHEN I_lhi =>
				TMP(0 TO N - 1) := STD_LOGIC_VECTOR(shift_left(UNSIGNED(DATA1), (N / 2)));
				OUTALU <= TMP(0 to N-1);
			WHEN I_slli | R_sll =>
				TMP(0 TO N - 1) := STD_LOGIC_VECTOR(shift_left(UNSIGNED(DATA1), to_integer(UNSIGNED(DATA2(N - 5 TO N - 1)))));
				OUTALU <= TMP(0 to N-1);
			WHEN I_srli | R_srl =>
				TMP(0 TO N - 1) := STD_LOGIC_VECTOR(shift_right(UNSIGNED(DATA1), to_integer(UNSIGNED(DATA2(N - 5 TO N - 1)))));
				OUTALU <= TMP(0 to N-1);
			WHEN I_srai | R_sra =>
				TMP(0 TO N - 1) := STD_LOGIC_VECTOR(shift_right(SIGNED(DATA1), to_integer(UNSIGNED(DATA2))));
				NEG <= TMP(N - 2);
				OUTALU <= TMP(0 to N-1);
			WHEN I_seqi | R_seq =>
				IF (SIGNED(DATA1) = SIGNED(DATA2)) THEN
					TMP(0) := '1';
				END IF;
				OUTALU <= TMP(0 to N-1);
			WHEN I_snei | R_sne =>
				IF (SIGNED(DATA1) /= SIGNED(DATA2)) THEN
					TMP(0) := '1';
				END IF;
				OUTALU <= TMP(0 to N-1);
			WHEN I_slti | R_slt =>
				IF (SIGNED(DATA1) < SIGNED(DATA2)) THEN
					TMP(0) := '1';
				END IF;
				OUTALU <= TMP(0 to N-1);
			WHEN I_sgti | R_sgt =>
				IF (SIGNED(DATA1) > SIGNED(DATA2)) THEN
					TMP(0) := '1';
				END IF;
				OUTALU <= TMP(0 to N-1);
			WHEN I_slei | R_sle =>
				IF (SIGNED(DATA1) <= SIGNED(DATA2)) THEN
					TMP(0) := '1';
				END IF;
				OUTALU <= TMP(0 to N-1);
			WHEN I_sgei | R_sge =>
				IF (SIGNED(DATA1) >= SIGNED(DATA2)) THEN
					TMP(0) := '1';
				END IF;
				OUTALU <= TMP(0 to N-1);
			WHEN I_sltui | R_sltu =>
				IF (UNSIGNED(DATA1) < UNSIGNED(DATA2)) THEN
					TMP(0) := '1';
				END IF;
				OUTALU <= TMP(0 to N-1);
			WHEN I_sgtui | R_sgtu =>
				IF (UNSIGNED(DATA1) > UNSIGNED(DATA2)) THEN
					TMP(0) := '1';
				END IF;
			WHEN I_sleui | R_sleu =>
				IF (UNSIGNED(DATA1) <= UNSIGNED(DATA2)) THEN
					TMP(0) := '1';
				END IF;
				OUTALU <= TMP(0 to N-1);
			WHEN I_sgeui | R_sgeu =>
				IF (UNSIGNED(DATA1) >= UNSIGNED(DATA2)) THEN
					TMP(0) := '1';
				END IF;
				OUTALU <= TMP(0 to N-1);
			WHEN R_mult =>
				TMP := STD_LOGIC_VECTOR(RESIZE(SIGNED(DATA1(0 TO (N / 2) - 1)),TMP'length) * RESIZE(SIGNED(DATA2(0 TO (N / 2) - 1)),TMP'length));
				NEG <= TMP(N - 2);
				OVF <= (DATA1(N - 1) AND DATA2(N - 1) AND NOT TMP(N - 1)) OR (NOT DATA1(N - 1) AND NOT DATA2(N - 1) AND TMP(N - 1));
				OUTALU <= STD_LOGIC_VECTOR(RESIZE(SIGNED(TMP),N));
			WHEN R_multu =>
				TMP := STD_LOGIC_VECTOR(RESIZE(UNSIGNED(DATA1(0 TO (N / 2) - 1)),TMP'length) * RESIZE(UNSIGNED(DATA2(0 TO (N / 2) - 1)),TMP'length));
				OVF <= TMP(N - 1);
				OUTALU <= STD_LOGIC_VECTOR(RESIZE(UNSIGNED(TMP),N));
			WHEN OTHERS => NULL; -- faults + NOP
		END CASE;

		IF (TMP = (TMP'RANGE => '0')) THEN
			ZERO <= '1';
		END IF;
		CARRY <= TMP(N - 1);

		--OUTALU <= TMP(0 to N-1); -- result assignment
	END PROCESS;
END ARITH;
