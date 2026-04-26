package v2;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: loaded from: classes.dex */
public final class b {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final /* synthetic */ b[] f6667a;

    static {
        b[] bVarArr = {new b("SRT_CMD_HS_REQ", 0), new b("SRT_CMD_HS_RSP", 1), new b("SRT_CMD_KM_REQ", 2), new b("SRT_CMD_KM_RSP", 3), new b("SRT_CMD_SID", 4), new b("SRT_CMD_CONGESTION", 5), new b("SRT_CMD_FILTER", 6), new b("SRT_CMD_GROUP", 7)};
        f6667a = bVarArr;
        H0.a.z(bVarArr);
    }

    public static b valueOf(String str) {
        return (b) Enum.valueOf(b.class, str);
    }

    public static b[] values() {
        return (b[]) f6667a.clone();
    }
}
