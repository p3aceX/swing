package d2;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: renamed from: d2.c, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class EnumC0355c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final /* synthetic */ EnumC0355c[] f3932a;

    static {
        EnumC0355c[] enumC0355cArr = {new EnumC0355c("SEQUENCE", 0), new EnumC0355c("NALU", 1), new EnumC0355c("EO_SEQ", 2)};
        f3932a = enumC0355cArr;
        H0.a.z(enumC0355cArr);
    }

    public static EnumC0355c valueOf(String str) {
        return (EnumC0355c) Enum.valueOf(EnumC0355c.class, str);
    }

    public static EnumC0355c[] values() {
        return (EnumC0355c[]) f3932a.clone();
    }
}
