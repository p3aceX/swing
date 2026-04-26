package X1;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: loaded from: classes.dex */
public final class j {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final j f2399b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final j f2400c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final j f2401d;
    public static final j e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final j f2402f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public static final j f2403m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public static final j f2404n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public static final j f2405o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public static final j f2406p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public static final j f2407q;

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public static final j f2408r;

    /* JADX INFO: renamed from: s, reason: collision with root package name */
    public static final j f2409s;

    /* JADX INFO: renamed from: t, reason: collision with root package name */
    public static final /* synthetic */ j[] f2410t;

    /* JADX INFO: renamed from: u, reason: collision with root package name */
    public static final /* synthetic */ B3.b f2411u;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final byte f2412a;

    static {
        j jVar = new j("NUMBER", 0, (byte) 0);
        f2399b = jVar;
        j jVar2 = new j("BOOLEAN", 1, (byte) 1);
        f2400c = jVar2;
        j jVar3 = new j("STRING", 2, (byte) 2);
        f2401d = jVar3;
        j jVar4 = new j("OBJECT", 3, (byte) 3);
        e = jVar4;
        j jVar5 = new j("NULL", 4, (byte) 5);
        f2402f = jVar5;
        j jVar6 = new j("UNDEFINED", 5, (byte) 6);
        f2403m = jVar6;
        j jVar7 = new j("ECMA_ARRAY", 6, (byte) 8);
        f2404n = jVar7;
        j jVar8 = new j("OBJECT_END", 7, (byte) 9);
        j jVar9 = new j("STRICT_ARRAY", 8, (byte) 10);
        f2405o = jVar9;
        j jVar10 = new j("DATE", 9, (byte) 11);
        f2406p = jVar10;
        j jVar11 = new j("LONG_STRING", 10, (byte) 12);
        f2407q = jVar11;
        j jVar12 = new j("UNSUPPORTED", 11, (byte) 13);
        f2408r = jVar12;
        j jVar13 = new j("XML_DOCUMENT", 12, (byte) 15);
        f2409s = jVar13;
        j[] jVarArr = {jVar, jVar2, jVar3, jVar4, jVar5, jVar6, jVar7, jVar8, jVar9, jVar10, jVar11, jVar12, jVar13, new j("REFERENCE", 13, (byte) 7), new j("TYPED_OBJECT", 14, (byte) 16), new j("AVM_PLUS_OBJECT", 15, (byte) 17), new j("MOVIE_CLIP", 16, (byte) 4), new j("RECORD_SET", 17, (byte) 14)};
        f2410t = jVarArr;
        f2411u = H0.a.z(jVarArr);
    }

    public j(String str, int i4, byte b5) {
        this.f2412a = b5;
    }

    public static j valueOf(String str) {
        return (j) Enum.valueOf(j.class, str);
    }

    public static j[] values() {
        return (j[]) f2410t.clone();
    }
}
