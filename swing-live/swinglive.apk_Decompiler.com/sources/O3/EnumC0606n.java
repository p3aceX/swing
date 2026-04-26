package o3;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: renamed from: o3.n, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class EnumC0606n {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final X.N f6121b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final EnumC0606n[] f6122c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final /* synthetic */ EnumC0606n[] f6123d;
    public static final /* synthetic */ B3.b e;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f6124a;

    /* JADX WARN: Multi-variable type inference failed */
    static {
        Object next;
        EnumC0606n[] enumC0606nArr = {new EnumC0606n("WARNING", 0, 1), new EnumC0606n("FATAL", 1, 2)};
        f6123d = enumC0606nArr;
        e = H0.a.z(enumC0606nArr);
        f6121b = new X.N(28);
        EnumC0606n[] enumC0606nArr2 = new EnumC0606n[256];
        for (int i4 = 0; i4 < 256; i4++) {
            B3.b bVar = e;
            bVar.getClass();
            J3.a aVar = new J3.a(bVar);
            while (true) {
                if (aVar.hasNext()) {
                    next = aVar.next();
                    if (((EnumC0606n) next).f6124a == i4) {
                        break;
                    }
                } else {
                    next = null;
                    break;
                }
            }
            enumC0606nArr2[i4] = next;
        }
        f6122c = enumC0606nArr2;
    }

    public EnumC0606n(String str, int i4, int i5) {
        this.f6124a = i5;
    }

    public static EnumC0606n valueOf(String str) {
        return (EnumC0606n) Enum.valueOf(EnumC0606n.class, str);
    }

    public static EnumC0606n[] values() {
        return (EnumC0606n[]) f6123d.clone();
    }
}
