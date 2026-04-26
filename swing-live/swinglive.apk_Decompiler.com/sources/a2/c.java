package a2;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: loaded from: classes.dex */
public final class c {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final c f2635b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final /* synthetic */ c[] f2636c;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f2637a;

    static {
        c cVar = new c("UNKNOWN", 0, 0);
        c cVar2 = new c("AAC_MAIN", 1, 1);
        c cVar3 = new c("AAC_LC", 2, 2);
        f2635b = cVar3;
        c[] cVarArr = {cVar, cVar2, cVar3, new c("AAC_SSR", 3, 3), new c("AAC_LTP", 4, 4), new c("AAC_SBR", 5, 5), new c("AAC_SCALABLE", 6, 6), new c("TWINQ_VQ", 7, 7), new c("CELP", 8, 8), new c("HXVC", 9, 9)};
        f2636c = cVarArr;
        H0.a.z(cVarArr);
    }

    public c(String str, int i4, int i5) {
        this.f2637a = i5;
    }

    public static c valueOf(String str) {
        return (c) Enum.valueOf(c.class, str);
    }

    public static c[] values() {
        return (c[]) f2636c.clone();
    }
}
