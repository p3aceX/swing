package Y1;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: loaded from: classes.dex */
public final class h {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final h f2508b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final h f2509c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final h f2510d;
    public static final h e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final h f2511f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public static final h f2512m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public static final h f2513n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public static final h f2514o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public static final h f2515p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public static final h f2516q;

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public static final /* synthetic */ h[] f2517r;

    /* JADX INFO: renamed from: s, reason: collision with root package name */
    public static final /* synthetic */ B3.b f2518s;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final byte f2519a;

    static {
        h hVar = new h("UNDEFINED", 0, (byte) 0);
        f2508b = hVar;
        h hVar2 = new h("NULL", 1, (byte) 1);
        f2509c = hVar2;
        h hVar3 = new h("TRUE", 2, (byte) 2);
        f2510d = hVar3;
        h hVar4 = new h("FALSE", 3, (byte) 3);
        e = hVar4;
        h hVar5 = new h("INTEGER", 4, (byte) 4);
        f2511f = hVar5;
        h hVar6 = new h("DOUBLE", 5, (byte) 5);
        f2512m = hVar6;
        h hVar7 = new h("STRING", 6, (byte) 6);
        f2513n = hVar7;
        h hVar8 = new h("XML_DOC", 7, (byte) 7);
        h hVar9 = new h("DATE", 8, (byte) 8);
        h hVar10 = new h("ARRAY", 9, (byte) 9);
        f2514o = hVar10;
        h hVar11 = new h("OBJECT", 10, (byte) 10);
        f2515p = hVar11;
        h hVar12 = new h("XML", 11, (byte) 11);
        h hVar13 = new h("BYTE_ARRAY", 12, (byte) 12);
        h hVar14 = new h("VECTOR_INT", 13, (byte) 13);
        h hVar15 = new h("VECTOR_UINT", 14, (byte) 14);
        h hVar16 = new h("VECTOR_DOUBLE", 15, (byte) 15);
        h hVar17 = new h("VECTOR_OBJECT", 16, (byte) 16);
        h hVar18 = new h("DICTIONARY", 17, (byte) 17);
        f2516q = hVar18;
        h[] hVarArr = {hVar, hVar2, hVar3, hVar4, hVar5, hVar6, hVar7, hVar8, hVar9, hVar10, hVar11, hVar12, hVar13, hVar14, hVar15, hVar16, hVar17, hVar18};
        f2517r = hVarArr;
        f2518s = H0.a.z(hVarArr);
    }

    public h(String str, int i4, byte b5) {
        this.f2519a = b5;
    }

    public static h valueOf(String str) {
        return (h) Enum.valueOf(h.class, str);
    }

    public static h[] values() {
        return (h[]) f2517r.clone();
    }
}
