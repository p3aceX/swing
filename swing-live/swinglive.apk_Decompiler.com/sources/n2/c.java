package N2;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: loaded from: classes.dex */
public final class c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final c f1133a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final /* synthetic */ c[] f1134b;

    static {
        c cVar = new c("PLAIN_TEXT", 0);
        f1133a = cVar;
        f1134b = new c[]{cVar};
    }

    public static c a(String str) throws NoSuchFieldException {
        for (c cVar : values()) {
            cVar.getClass();
            if ("text/plain".equals(str)) {
                return cVar;
            }
        }
        throw new NoSuchFieldException(B1.a.m("No such ClipboardContentFormat: ", str));
    }

    public static c valueOf(String str) {
        return (c) Enum.valueOf(c.class, str);
    }

    public static c[] values() {
        return (c[]) f1134b.clone();
    }
}
