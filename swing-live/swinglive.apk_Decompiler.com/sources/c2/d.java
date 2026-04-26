package c2;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: loaded from: classes.dex */
public final class d {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final /* synthetic */ d[] f3299a;

    static {
        d[] dVarArr = {new d("UNSPEC", 0), new d("SLICE", 1), new d("DPA", 2), new d("DPB", 3), new d("DPC", 4), new d("IDR", 5), new d("SEI", 6), new d("SPS", 7), new d("PPS", 8), new d("AUD", 9), new d("EO_SEQ", 10), new d("EO_STREAM", 11), new d("FILL", 12), new d("HEVC_VPS", 13), new d("HEVC_SPS", 14), new d("HEVC_PPS", 15), new d("IDR_N_LP", 16), new d("IDR_W_DLP", 17)};
        f3299a = dVarArr;
        H0.a.z(dVarArr);
    }

    public static d valueOf(String str) {
        return (d) Enum.valueOf(d.class, str);
    }

    public static d[] values() {
        return (d[]) f3299a.clone();
    }
}
