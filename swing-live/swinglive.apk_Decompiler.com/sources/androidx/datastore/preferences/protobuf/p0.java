package androidx.datastore.preferences.protobuf;

/* JADX WARN: Enum visitor error
jadx.core.utils.exceptions.JadxRuntimeException: Init of enum field 'EF12' uses external variables
	at jadx.core.dex.visitors.EnumVisitor.createEnumFieldByConstructor(EnumVisitor.java:451)
	at jadx.core.dex.visitors.EnumVisitor.processEnumFieldByRegister(EnumVisitor.java:395)
	at jadx.core.dex.visitors.EnumVisitor.extractEnumFieldsFromFilledArray(EnumVisitor.java:324)
	at jadx.core.dex.visitors.EnumVisitor.extractEnumFieldsFromInsn(EnumVisitor.java:262)
	at jadx.core.dex.visitors.EnumVisitor.convertToEnum(EnumVisitor.java:151)
	at jadx.core.dex.visitors.EnumVisitor.visit(EnumVisitor.java:100)
 */
/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX INFO: loaded from: classes.dex */
public class p0 {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final l0 f3013c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final m0 f3014d;
    public static final n0 e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final /* synthetic */ p0[] f3015f;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final q0 f3016a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f3017b;

    /* JADX INFO: Fake field, exist only in values array */
    p0 EF10;

    /* JADX INFO: Fake field, exist only in values array */
    p0 EF11;

    /* JADX INFO: Fake field, exist only in values array */
    p0 EF12;

    static {
        p0 p0Var = new p0("DOUBLE", 0, q0.DOUBLE, 1);
        p0 p0Var2 = new p0("FLOAT", 1, q0.FLOAT, 5);
        q0 q0Var = q0.LONG;
        p0 p0Var3 = new p0("INT64", 2, q0Var, 0);
        p0 p0Var4 = new p0("UINT64", 3, q0Var, 0);
        q0 q0Var2 = q0.INT;
        p0 p0Var5 = new p0("INT32", 4, q0Var2, 0);
        p0 p0Var6 = new p0("FIXED64", 5, q0Var, 1);
        p0 p0Var7 = new p0("FIXED32", 6, q0Var2, 5);
        p0 p0Var8 = new p0("BOOL", 7, q0.BOOLEAN, 0);
        l0 l0Var = new l0("STRING", 8, q0.STRING, 2);
        f3013c = l0Var;
        q0 q0Var3 = q0.MESSAGE;
        m0 m0Var = new m0("GROUP", 9, q0Var3, 3);
        f3014d = m0Var;
        n0 n0Var = new n0("MESSAGE", 10, q0Var3, 2);
        e = n0Var;
        f3015f = new p0[]{p0Var, p0Var2, p0Var3, p0Var4, p0Var5, p0Var6, p0Var7, p0Var8, l0Var, m0Var, n0Var, new o0("BYTES", 11, q0.BYTE_STRING, 2), new p0("UINT32", 12, q0Var2, 0), new p0("ENUM", 13, q0.ENUM, 0), new p0("SFIXED32", 14, q0Var2, 5), new p0("SFIXED64", 15, q0Var, 1), new p0("SINT32", 16, q0Var2, 0), new p0("SINT64", 17, q0Var, 0)};
    }

    public p0(String str, int i4, q0 q0Var, int i5) {
        this.f3016a = q0Var;
        this.f3017b = i5;
    }

    public static p0 valueOf(String str) {
        return (p0) Enum.valueOf(p0.class, str);
    }

    public static p0[] values() {
        return (p0[]) f3015f.clone();
    }
}
