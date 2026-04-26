package androidx.datastore.preferences.protobuf;

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
/* JADX INFO: renamed from: androidx.datastore.preferences.protobuf.q, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class EnumC0206q {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final EnumC0206q f3018b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final EnumC0206q f3019c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final EnumC0206q[] f3020d;
    public static final /* synthetic */ EnumC0206q[] e;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f3021a;

    /* JADX INFO: Fake field, exist only in values array */
    EnumC0206q EF0;

    static {
        EnumC0214z enumC0214z = EnumC0214z.DOUBLE;
        EnumC0206q enumC0206q = new EnumC0206q("DOUBLE", 0, 0, 1, enumC0214z);
        EnumC0214z enumC0214z2 = EnumC0214z.FLOAT;
        EnumC0206q enumC0206q2 = new EnumC0206q("FLOAT", 1, 1, 1, enumC0214z2);
        EnumC0214z enumC0214z3 = EnumC0214z.LONG;
        EnumC0206q enumC0206q3 = new EnumC0206q("INT64", 2, 2, 1, enumC0214z3);
        EnumC0206q enumC0206q4 = new EnumC0206q("UINT64", 3, 3, 1, enumC0214z3);
        EnumC0214z enumC0214z4 = EnumC0214z.INT;
        EnumC0206q enumC0206q5 = new EnumC0206q("INT32", 4, 4, 1, enumC0214z4);
        EnumC0206q enumC0206q6 = new EnumC0206q("FIXED64", 5, 5, 1, enumC0214z3);
        EnumC0206q enumC0206q7 = new EnumC0206q("FIXED32", 6, 6, 1, enumC0214z4);
        EnumC0214z enumC0214z5 = EnumC0214z.BOOLEAN;
        EnumC0206q enumC0206q8 = new EnumC0206q("BOOL", 7, 7, 1, enumC0214z5);
        EnumC0214z enumC0214z6 = EnumC0214z.STRING;
        EnumC0206q enumC0206q9 = new EnumC0206q("STRING", 8, 8, 1, enumC0214z6);
        EnumC0214z enumC0214z7 = EnumC0214z.MESSAGE;
        EnumC0206q enumC0206q10 = new EnumC0206q("MESSAGE", 9, 9, 1, enumC0214z7);
        EnumC0214z enumC0214z8 = EnumC0214z.BYTE_STRING;
        EnumC0206q enumC0206q11 = new EnumC0206q("BYTES", 10, 10, 1, enumC0214z8);
        EnumC0206q enumC0206q12 = new EnumC0206q("UINT32", 11, 11, 1, enumC0214z4);
        EnumC0214z enumC0214z9 = EnumC0214z.ENUM;
        EnumC0206q enumC0206q13 = new EnumC0206q("ENUM", 12, 12, 1, enumC0214z9);
        EnumC0206q enumC0206q14 = new EnumC0206q("SFIXED32", 13, 13, 1, enumC0214z4);
        EnumC0206q enumC0206q15 = new EnumC0206q("SFIXED64", 14, 14, 1, enumC0214z3);
        EnumC0206q enumC0206q16 = new EnumC0206q("SINT32", 15, 15, 1, enumC0214z4);
        EnumC0206q enumC0206q17 = new EnumC0206q("SINT64", 16, 16, 1, enumC0214z3);
        EnumC0206q enumC0206q18 = new EnumC0206q("GROUP", 17, 17, 1, enumC0214z7);
        EnumC0206q enumC0206q19 = new EnumC0206q("DOUBLE_LIST", 18, 18, 2, enumC0214z);
        EnumC0206q enumC0206q20 = new EnumC0206q("FLOAT_LIST", 19, 19, 2, enumC0214z2);
        EnumC0206q enumC0206q21 = new EnumC0206q("INT64_LIST", 20, 20, 2, enumC0214z3);
        EnumC0206q enumC0206q22 = new EnumC0206q("UINT64_LIST", 21, 21, 2, enumC0214z3);
        EnumC0206q enumC0206q23 = new EnumC0206q("INT32_LIST", 22, 22, 2, enumC0214z4);
        EnumC0206q enumC0206q24 = new EnumC0206q("FIXED64_LIST", 23, 23, 2, enumC0214z3);
        EnumC0206q enumC0206q25 = new EnumC0206q("FIXED32_LIST", 24, 24, 2, enumC0214z4);
        EnumC0206q enumC0206q26 = new EnumC0206q("BOOL_LIST", 25, 25, 2, enumC0214z5);
        EnumC0206q enumC0206q27 = new EnumC0206q("STRING_LIST", 26, 26, 2, enumC0214z6);
        EnumC0206q enumC0206q28 = new EnumC0206q("MESSAGE_LIST", 27, 27, 2, enumC0214z7);
        EnumC0206q enumC0206q29 = new EnumC0206q("BYTES_LIST", 28, 28, 2, enumC0214z8);
        EnumC0206q enumC0206q30 = new EnumC0206q("UINT32_LIST", 29, 29, 2, enumC0214z4);
        EnumC0206q enumC0206q31 = new EnumC0206q("ENUM_LIST", 30, 30, 2, enumC0214z9);
        EnumC0206q enumC0206q32 = new EnumC0206q("SFIXED32_LIST", 31, 31, 2, enumC0214z4);
        EnumC0206q enumC0206q33 = new EnumC0206q("SFIXED64_LIST", 32, 32, 2, enumC0214z3);
        EnumC0206q enumC0206q34 = new EnumC0206q("SINT32_LIST", 33, 33, 2, enumC0214z4);
        EnumC0206q enumC0206q35 = new EnumC0206q("SINT64_LIST", 34, 34, 2, enumC0214z3);
        EnumC0206q enumC0206q36 = new EnumC0206q("DOUBLE_LIST_PACKED", 35, 35, 3, enumC0214z);
        f3018b = enumC0206q36;
        EnumC0206q enumC0206q37 = new EnumC0206q("FLOAT_LIST_PACKED", 36, 36, 3, enumC0214z2);
        EnumC0206q enumC0206q38 = new EnumC0206q("INT64_LIST_PACKED", 37, 37, 3, enumC0214z3);
        EnumC0206q enumC0206q39 = new EnumC0206q("UINT64_LIST_PACKED", 38, 38, 3, enumC0214z3);
        EnumC0206q enumC0206q40 = new EnumC0206q("INT32_LIST_PACKED", 39, 39, 3, enumC0214z4);
        EnumC0206q enumC0206q41 = new EnumC0206q("FIXED64_LIST_PACKED", 40, 40, 3, enumC0214z3);
        EnumC0206q enumC0206q42 = new EnumC0206q("FIXED32_LIST_PACKED", 41, 41, 3, enumC0214z4);
        EnumC0206q enumC0206q43 = new EnumC0206q("BOOL_LIST_PACKED", 42, 42, 3, enumC0214z5);
        EnumC0206q enumC0206q44 = new EnumC0206q("UINT32_LIST_PACKED", 43, 43, 3, enumC0214z4);
        EnumC0206q enumC0206q45 = new EnumC0206q("ENUM_LIST_PACKED", 44, 44, 3, enumC0214z9);
        EnumC0206q enumC0206q46 = new EnumC0206q("SFIXED32_LIST_PACKED", 45, 45, 3, enumC0214z4);
        EnumC0206q enumC0206q47 = new EnumC0206q("SFIXED64_LIST_PACKED", 46, 46, 3, enumC0214z3);
        EnumC0206q enumC0206q48 = new EnumC0206q("SINT32_LIST_PACKED", 47, 47, 3, enumC0214z4);
        EnumC0206q enumC0206q49 = new EnumC0206q("SINT64_LIST_PACKED", 48, 48, 3, enumC0214z3);
        f3019c = enumC0206q49;
        e = new EnumC0206q[]{enumC0206q, enumC0206q2, enumC0206q3, enumC0206q4, enumC0206q5, enumC0206q6, enumC0206q7, enumC0206q8, enumC0206q9, enumC0206q10, enumC0206q11, enumC0206q12, enumC0206q13, enumC0206q14, enumC0206q15, enumC0206q16, enumC0206q17, enumC0206q18, enumC0206q19, enumC0206q20, enumC0206q21, enumC0206q22, enumC0206q23, enumC0206q24, enumC0206q25, enumC0206q26, enumC0206q27, enumC0206q28, enumC0206q29, enumC0206q30, enumC0206q31, enumC0206q32, enumC0206q33, enumC0206q34, enumC0206q35, enumC0206q36, enumC0206q37, enumC0206q38, enumC0206q39, enumC0206q40, enumC0206q41, enumC0206q42, enumC0206q43, enumC0206q44, enumC0206q45, enumC0206q46, enumC0206q47, enumC0206q48, enumC0206q49, new EnumC0206q("GROUP_LIST", 49, 49, 2, enumC0214z7), new EnumC0206q("MAP", 50, 50, 4, EnumC0214z.VOID)};
        EnumC0206q[] enumC0206qArrValues = values();
        f3020d = new EnumC0206q[enumC0206qArrValues.length];
        for (EnumC0206q enumC0206q50 : enumC0206qArrValues) {
            f3020d[enumC0206q50.f3021a] = enumC0206q50;
        }
    }

    public EnumC0206q(String str, int i4, int i5, int i6, EnumC0214z enumC0214z) {
        this.f3021a = i5;
        int iB = K.j.b(i6);
        if (iB == 1 || iB == 3) {
            enumC0214z.getClass();
        }
        if (i6 == 1) {
            enumC0214z.ordinal();
        }
    }

    public static EnumC0206q valueOf(String str) {
        return (EnumC0206q) Enum.valueOf(EnumC0206q.class, str);
    }

    public static EnumC0206q[] values() {
        return (EnumC0206q[]) e.clone();
    }
}
