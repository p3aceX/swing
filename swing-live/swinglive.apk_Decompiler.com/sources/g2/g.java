package g2;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: loaded from: classes.dex */
public final class g {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final g f4339b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final g f4340c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final g f4341d;
    public static final g e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final g f4342f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public static final g f4343m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public static final g f4344n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public static final g f4345o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public static final g f4346p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public static final g f4347q;

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public static final g f4348r;

    /* JADX INFO: renamed from: s, reason: collision with root package name */
    public static final g f4349s;

    /* JADX INFO: renamed from: t, reason: collision with root package name */
    public static final g f4350t;

    /* JADX INFO: renamed from: u, reason: collision with root package name */
    public static final g f4351u;
    public static final g v;

    /* JADX INFO: renamed from: w, reason: collision with root package name */
    public static final /* synthetic */ g[] f4352w;

    /* JADX INFO: renamed from: x, reason: collision with root package name */
    public static final /* synthetic */ B3.b f4353x;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final byte f4354a;

    static {
        g gVar = new g("SET_CHUNK_SIZE", 0, (byte) 1);
        f4339b = gVar;
        g gVar2 = new g("ABORT", 1, (byte) 2);
        f4340c = gVar2;
        g gVar3 = new g("ACKNOWLEDGEMENT", 2, (byte) 3);
        f4341d = gVar3;
        g gVar4 = new g("USER_CONTROL", 3, (byte) 4);
        e = gVar4;
        g gVar5 = new g("WINDOW_ACKNOWLEDGEMENT_SIZE", 4, (byte) 5);
        f4342f = gVar5;
        g gVar6 = new g("SET_PEER_BANDWIDTH", 5, (byte) 6);
        f4343m = gVar6;
        g gVar7 = new g("AUDIO", 6, (byte) 8);
        f4344n = gVar7;
        g gVar8 = new g("VIDEO", 7, (byte) 9);
        f4345o = gVar8;
        g gVar9 = new g("DATA_AMF3", 8, (byte) 15);
        f4346p = gVar9;
        g gVar10 = new g("SHARED_OBJECT_AMF3", 9, (byte) 16);
        f4347q = gVar10;
        g gVar11 = new g("COMMAND_AMF3", 10, (byte) 17);
        f4348r = gVar11;
        g gVar12 = new g("DATA_AMF0", 11, (byte) 18);
        f4349s = gVar12;
        g gVar13 = new g("SHARED_OBJECT_AMF0", 12, (byte) 19);
        f4350t = gVar13;
        g gVar14 = new g("COMMAND_AMF0", 13, (byte) 20);
        f4351u = gVar14;
        g gVar15 = new g("AGGREGATE", 14, (byte) 22);
        v = gVar15;
        g[] gVarArr = {gVar, gVar2, gVar3, gVar4, gVar5, gVar6, gVar7, gVar8, gVar9, gVar10, gVar11, gVar12, gVar13, gVar14, gVar15};
        f4352w = gVarArr;
        f4353x = H0.a.z(gVarArr);
    }

    public g(String str, int i4, byte b5) {
        this.f4354a = b5;
    }

    public static g valueOf(String str) {
        return (g) Enum.valueOf(g.class, str);
    }

    public static g[] values() {
        return (g[]) f4352w.clone();
    }
}
