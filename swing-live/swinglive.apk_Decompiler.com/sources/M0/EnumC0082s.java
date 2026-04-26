package M0;

/* JADX INFO: renamed from: M0.s, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public enum EnumC0082s implements InterfaceC0065a {
    /* JADX INFO: Fake field, exist only in values array */
    ED256(-260),
    /* JADX INFO: Fake field, exist only in values array */
    ED512(-261),
    /* JADX INFO: Fake field, exist only in values array */
    ED25519(-8),
    /* JADX INFO: Fake field, exist only in values array */
    ES256(-7),
    /* JADX INFO: Fake field, exist only in values array */
    ES384(-35),
    /* JADX INFO: Fake field, exist only in values array */
    ES512(-36);


    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f1035a;

    EnumC0082s(int i4) {
        this.f1035a = i4;
    }

    @Override // M0.InterfaceC0065a
    public final int a() {
        return this.f1035a;
    }
}
