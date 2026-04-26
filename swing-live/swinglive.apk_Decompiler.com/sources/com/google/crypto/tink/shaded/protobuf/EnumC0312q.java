package com.google.crypto.tink.shaded.protobuf;

/* JADX WARN: Enum visitor error
jadx.core.utils.exceptions.JadxRuntimeException: Init of enum field 'EF0' uses external variables
	at jadx.core.dex.visitors.EnumVisitor.createEnumFieldByConstructor(EnumVisitor.java:451)
	at jadx.core.dex.visitors.EnumVisitor.processEnumFieldByRegister(EnumVisitor.java:395)
	at jadx.core.dex.visitors.EnumVisitor.extractEnumFieldsFromFilledArray(EnumVisitor.java:324)
	at jadx.core.dex.visitors.EnumVisitor.extractEnumFieldsFromInsn(EnumVisitor.java:262)
	at jadx.core.dex.visitors.EnumVisitor.convertToEnum(EnumVisitor.java:151)
	at jadx.core.dex.visitors.EnumVisitor.visit(EnumVisitor.java:100)
 */
/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX INFO: renamed from: com.google.crypto.tink.shaded.protobuf.q, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class EnumC0312q {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final EnumC0312q f3830b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final EnumC0312q f3831c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final EnumC0312q[] f3832d;
    public static final /* synthetic */ EnumC0312q[] e;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f3833a;

    /* JADX INFO: Fake field, exist only in values array */
    EnumC0312q EF0;

    static {
        C c5 = C.DOUBLE;
        EnumC0312q enumC0312q = new EnumC0312q("DOUBLE", 0, 0, 1, c5);
        C c6 = C.FLOAT;
        EnumC0312q enumC0312q2 = new EnumC0312q("FLOAT", 1, 1, 1, c6);
        C c7 = C.LONG;
        EnumC0312q enumC0312q3 = new EnumC0312q("INT64", 2, 2, 1, c7);
        EnumC0312q enumC0312q4 = new EnumC0312q("UINT64", 3, 3, 1, c7);
        C c8 = C.INT;
        EnumC0312q enumC0312q5 = new EnumC0312q("INT32", 4, 4, 1, c8);
        EnumC0312q enumC0312q6 = new EnumC0312q("FIXED64", 5, 5, 1, c7);
        EnumC0312q enumC0312q7 = new EnumC0312q("FIXED32", 6, 6, 1, c8);
        C c9 = C.BOOLEAN;
        EnumC0312q enumC0312q8 = new EnumC0312q("BOOL", 7, 7, 1, c9);
        C c10 = C.STRING;
        EnumC0312q enumC0312q9 = new EnumC0312q("STRING", 8, 8, 1, c10);
        C c11 = C.MESSAGE;
        EnumC0312q enumC0312q10 = new EnumC0312q("MESSAGE", 9, 9, 1, c11);
        C c12 = C.BYTE_STRING;
        EnumC0312q enumC0312q11 = new EnumC0312q("BYTES", 10, 10, 1, c12);
        EnumC0312q enumC0312q12 = new EnumC0312q("UINT32", 11, 11, 1, c8);
        C c13 = C.ENUM;
        EnumC0312q enumC0312q13 = new EnumC0312q("ENUM", 12, 12, 1, c13);
        EnumC0312q enumC0312q14 = new EnumC0312q("SFIXED32", 13, 13, 1, c8);
        EnumC0312q enumC0312q15 = new EnumC0312q("SFIXED64", 14, 14, 1, c7);
        EnumC0312q enumC0312q16 = new EnumC0312q("SINT32", 15, 15, 1, c8);
        EnumC0312q enumC0312q17 = new EnumC0312q("SINT64", 16, 16, 1, c7);
        EnumC0312q enumC0312q18 = new EnumC0312q("GROUP", 17, 17, 1, c11);
        EnumC0312q enumC0312q19 = new EnumC0312q("DOUBLE_LIST", 18, 18, 2, c5);
        EnumC0312q enumC0312q20 = new EnumC0312q("FLOAT_LIST", 19, 19, 2, c6);
        EnumC0312q enumC0312q21 = new EnumC0312q("INT64_LIST", 20, 20, 2, c7);
        EnumC0312q enumC0312q22 = new EnumC0312q("UINT64_LIST", 21, 21, 2, c7);
        EnumC0312q enumC0312q23 = new EnumC0312q("INT32_LIST", 22, 22, 2, c8);
        EnumC0312q enumC0312q24 = new EnumC0312q("FIXED64_LIST", 23, 23, 2, c7);
        EnumC0312q enumC0312q25 = new EnumC0312q("FIXED32_LIST", 24, 24, 2, c8);
        EnumC0312q enumC0312q26 = new EnumC0312q("BOOL_LIST", 25, 25, 2, c9);
        EnumC0312q enumC0312q27 = new EnumC0312q("STRING_LIST", 26, 26, 2, c10);
        EnumC0312q enumC0312q28 = new EnumC0312q("MESSAGE_LIST", 27, 27, 2, c11);
        EnumC0312q enumC0312q29 = new EnumC0312q("BYTES_LIST", 28, 28, 2, c12);
        EnumC0312q enumC0312q30 = new EnumC0312q("UINT32_LIST", 29, 29, 2, c8);
        EnumC0312q enumC0312q31 = new EnumC0312q("ENUM_LIST", 30, 30, 2, c13);
        EnumC0312q enumC0312q32 = new EnumC0312q("SFIXED32_LIST", 31, 31, 2, c8);
        EnumC0312q enumC0312q33 = new EnumC0312q("SFIXED64_LIST", 32, 32, 2, c7);
        EnumC0312q enumC0312q34 = new EnumC0312q("SINT32_LIST", 33, 33, 2, c8);
        EnumC0312q enumC0312q35 = new EnumC0312q("SINT64_LIST", 34, 34, 2, c7);
        EnumC0312q enumC0312q36 = new EnumC0312q("DOUBLE_LIST_PACKED", 35, 35, 3, c5);
        f3830b = enumC0312q36;
        EnumC0312q enumC0312q37 = new EnumC0312q("FLOAT_LIST_PACKED", 36, 36, 3, c6);
        EnumC0312q enumC0312q38 = new EnumC0312q("INT64_LIST_PACKED", 37, 37, 3, c7);
        EnumC0312q enumC0312q39 = new EnumC0312q("UINT64_LIST_PACKED", 38, 38, 3, c7);
        EnumC0312q enumC0312q40 = new EnumC0312q("INT32_LIST_PACKED", 39, 39, 3, c8);
        EnumC0312q enumC0312q41 = new EnumC0312q("FIXED64_LIST_PACKED", 40, 40, 3, c7);
        EnumC0312q enumC0312q42 = new EnumC0312q("FIXED32_LIST_PACKED", 41, 41, 3, c8);
        EnumC0312q enumC0312q43 = new EnumC0312q("BOOL_LIST_PACKED", 42, 42, 3, c9);
        EnumC0312q enumC0312q44 = new EnumC0312q("UINT32_LIST_PACKED", 43, 43, 3, c8);
        EnumC0312q enumC0312q45 = new EnumC0312q("ENUM_LIST_PACKED", 44, 44, 3, c13);
        EnumC0312q enumC0312q46 = new EnumC0312q("SFIXED32_LIST_PACKED", 45, 45, 3, c8);
        EnumC0312q enumC0312q47 = new EnumC0312q("SFIXED64_LIST_PACKED", 46, 46, 3, c7);
        EnumC0312q enumC0312q48 = new EnumC0312q("SINT32_LIST_PACKED", 47, 47, 3, c8);
        EnumC0312q enumC0312q49 = new EnumC0312q("SINT64_LIST_PACKED", 48, 48, 3, c7);
        f3831c = enumC0312q49;
        e = new EnumC0312q[]{enumC0312q, enumC0312q2, enumC0312q3, enumC0312q4, enumC0312q5, enumC0312q6, enumC0312q7, enumC0312q8, enumC0312q9, enumC0312q10, enumC0312q11, enumC0312q12, enumC0312q13, enumC0312q14, enumC0312q15, enumC0312q16, enumC0312q17, enumC0312q18, enumC0312q19, enumC0312q20, enumC0312q21, enumC0312q22, enumC0312q23, enumC0312q24, enumC0312q25, enumC0312q26, enumC0312q27, enumC0312q28, enumC0312q29, enumC0312q30, enumC0312q31, enumC0312q32, enumC0312q33, enumC0312q34, enumC0312q35, enumC0312q36, enumC0312q37, enumC0312q38, enumC0312q39, enumC0312q40, enumC0312q41, enumC0312q42, enumC0312q43, enumC0312q44, enumC0312q45, enumC0312q46, enumC0312q47, enumC0312q48, enumC0312q49, new EnumC0312q("GROUP_LIST", 49, 49, 2, c11), new EnumC0312q("MAP", 50, 50, 4, C.VOID)};
        EnumC0312q[] enumC0312qArrValues = values();
        f3832d = new EnumC0312q[enumC0312qArrValues.length];
        for (EnumC0312q enumC0312q50 : enumC0312qArrValues) {
            f3832d[enumC0312q50.f3833a] = enumC0312q50;
        }
    }

    public EnumC0312q(String str, int i4, int i5, int i6, C c5) {
        this.f3833a = i5;
        int iB = K.j.b(i6);
        if (iB == 1 || iB == 3) {
            c5.getClass();
        }
        if (i6 == 1) {
            c5.ordinal();
        }
    }

    public static EnumC0312q valueOf(String str) {
        return (EnumC0312q) Enum.valueOf(EnumC0312q.class, str);
    }

    public static EnumC0312q[] values() {
        return (EnumC0312q[]) e.clone();
    }
}
