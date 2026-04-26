package o3;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: renamed from: o3.c, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class EnumC0595c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final EnumC0595c f6081a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final EnumC0595c f6082b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final /* synthetic */ EnumC0595c[] f6083c;

    static {
        EnumC0595c enumC0595c = new EnumC0595c("GCM", 0);
        f6081a = enumC0595c;
        EnumC0595c enumC0595c2 = new EnumC0595c("CBC", 1);
        f6082b = enumC0595c2;
        EnumC0595c[] enumC0595cArr = {enumC0595c, enumC0595c2};
        f6083c = enumC0595cArr;
        H0.a.z(enumC0595cArr);
    }

    public static EnumC0595c valueOf(String str) {
        return (EnumC0595c) Enum.valueOf(EnumC0595c.class, str);
    }

    public static EnumC0595c[] values() {
        return (EnumC0595c[]) f6083c.clone();
    }
}
