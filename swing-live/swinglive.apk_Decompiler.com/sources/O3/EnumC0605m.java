package o3;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: renamed from: o3.m, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class EnumC0605m {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final X.N f6117b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final EnumC0605m[] f6118c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final /* synthetic */ EnumC0605m[] f6119d;
    public static final /* synthetic */ B3.b e;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f6120a;

    /* JADX WARN: Multi-variable type inference failed */
    static {
        Object next;
        EnumC0605m[] enumC0605mArr = {new EnumC0605m("ExplicitPrime", 0, 1), new EnumC0605m("ExplicitChar", 1, 2), new EnumC0605m("NamedCurve", 2, 3)};
        f6119d = enumC0605mArr;
        e = H0.a.z(enumC0605mArr);
        f6117b = new X.N(27);
        EnumC0605m[] enumC0605mArr2 = new EnumC0605m[256];
        for (int i4 = 0; i4 < 256; i4++) {
            B3.b bVar = e;
            bVar.getClass();
            J3.a aVar = new J3.a(bVar);
            while (true) {
                if (aVar.hasNext()) {
                    next = aVar.next();
                    if (((EnumC0605m) next).f6120a == i4) {
                        break;
                    }
                } else {
                    next = null;
                    break;
                }
            }
            enumC0605mArr2[i4] = next;
        }
        f6118c = enumC0605mArr2;
    }

    public EnumC0605m(String str, int i4, int i5) {
        this.f6120a = i5;
    }

    public static EnumC0605m valueOf(String str) {
        return (EnumC0605m) Enum.valueOf(EnumC0605m.class, str);
    }

    public static EnumC0605m[] values() {
        return (EnumC0605m[]) f6119d.clone();
    }
}
