package s2;

import o3.C0592H;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: loaded from: classes.dex */
public final class c {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final C0592H f6489b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final c f6490c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final /* synthetic */ c[] f6491d;
    public static final /* synthetic */ B3.b e;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f6492a;

    static {
        c cVar = new c("DATA", 0, 0);
        c cVar2 = new c("CONTROL", 1, 1);
        f6490c = cVar2;
        c[] cVarArr = {cVar, cVar2};
        f6491d = cVarArr;
        e = H0.a.z(cVarArr);
        f6489b = new C0592H();
    }

    public c(String str, int i4, int i5) {
        this.f6492a = i5;
    }

    public static c valueOf(String str) {
        return (c) Enum.valueOf(c.class, str);
    }

    public static c[] values() {
        return (c[]) f6491d.clone();
    }
}
