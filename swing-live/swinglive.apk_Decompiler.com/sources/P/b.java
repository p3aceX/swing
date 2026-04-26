package P;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: loaded from: classes.dex */
public final class b {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final b f1470a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final b f1471b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final b f1472c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final /* synthetic */ b[] f1473d;

    /* JADX INFO: Fake field, exist only in values array */
    b EF0;

    static {
        b bVar = new b("PENALTY_LOG", 0);
        b bVar2 = new b("PENALTY_DEATH", 1);
        b bVar3 = new b("DETECT_FRAGMENT_REUSE", 2);
        f1470a = bVar3;
        b bVar4 = new b("DETECT_FRAGMENT_TAG_USAGE", 3);
        f1471b = bVar4;
        b bVar5 = new b("DETECT_WRONG_NESTED_HIERARCHY", 4);
        b bVar6 = new b("DETECT_RETAIN_INSTANCE_USAGE", 5);
        b bVar7 = new b("DETECT_SET_USER_VISIBLE_HINT", 6);
        b bVar8 = new b("DETECT_TARGET_FRAGMENT_USAGE", 7);
        b bVar9 = new b("DETECT_WRONG_FRAGMENT_CONTAINER", 8);
        f1472c = bVar9;
        f1473d = new b[]{bVar, bVar2, bVar3, bVar4, bVar5, bVar6, bVar7, bVar8, bVar9};
    }

    public static b valueOf(String str) {
        return (b) Enum.valueOf(b.class, str);
    }

    public static b[] values() {
        return (b[]) f1473d.clone();
    }
}
