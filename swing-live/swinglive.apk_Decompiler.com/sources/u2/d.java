package u2;

import o3.C0592H;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: loaded from: classes.dex */
public final class d {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final C0592H f6660b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final d f6661c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final d f6662d;
    public static final /* synthetic */ d[] e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final /* synthetic */ B3.b f6663f;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f6664a;

    static {
        d dVar = new d("DONE", 0, -3);
        d dVar2 = new d("AGREEMENT", 1, -2);
        d dVar3 = new d("CONCLUSION", 2, -1);
        f6661c = dVar3;
        d dVar4 = new d("WAVE_A_HAND", 3, 0);
        d dVar5 = new d("INDUCTION", 4, 1);
        f6662d = dVar5;
        d[] dVarArr = {dVar, dVar2, dVar3, dVar4, dVar5, new d("SRT_REJ_UNKNOWN", 5, 1000), new d("SRT_REJ_SYSTEM", 6, 1001), new d("SRT_REJ_PEER", 7, 1002), new d("SRT_REJ_RESOURCE", 8, 1003), new d("SRT_REJ_ROGUE", 9, 1004), new d("SRT_REJ_BACKLOG", 10, 1005), new d("SRT_REJ_IPE", 11, 1006), new d("SRT_REJ_CLOSE", 12, 1007), new d("SRT_REJ_VERSION", 13, 1008), new d("SRT_REJ_RDVCOOKIE", 14, 1009), new d("SRT_REJ_BADSECRET", 15, 1010), new d("SRT_REJ_UNSECURE", 16, 1011), new d("SRT_REJ_MESSAGEAPI", 17, 1012), new d("SRT_REJ_CONGESTION", 18, 1013), new d("SRT_REJ_FILTER", 19, 1014), new d("SRT_REJ_GROUP", 20, 1015), new d("SRT_REJ_TIMEOUT", 21, 1016), new d("SRT_REJ_CRYPTO", 22, 1017)};
        e = dVarArr;
        f6663f = H0.a.z(dVarArr);
        f6660b = new C0592H();
    }

    public d(String str, int i4, int i5) {
        this.f6664a = i5;
    }

    public static d valueOf(String str) {
        return (d) Enum.valueOf(d.class, str);
    }

    public static d[] values() {
        return (d[]) e.clone();
    }
}
