package p2;

import J3.i;
import n2.AbstractC0561d;
import q2.C0635a;

/* JADX INFO: renamed from: p2.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0617a extends AbstractC0561d {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final byte f6189c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final short f6190d;
    public byte e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final boolean f6191f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public final /* synthetic */ int f6192g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public C0635a f6193h;

    /* JADX WARN: 'this' call moved to the top of the method (can break code semantics) */
    public /* synthetic */ C0617a(int i4, byte b5, short s4, int i5, int i6) {
        this(i4, b5, s4, i5);
        this.f6192g = i6;
    }

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0617a(int i4, byte b5, short s4, int i5) {
        super(i4, false);
        boolean z4 = (i5 & 32) == 0;
        this.f6189c = b5;
        this.f6190d = s4;
        this.e = (byte) 0;
        this.f6191f = z4;
    }

    /* JADX WARN: 'this' call moved to the top of the method (can break code semantics) */
    public C0617a(int i4, C0635a c0635a) {
        this(i4, (byte) 2, c0635a.f6260b, 496);
        this.f6192g = 1;
        i.e(c0635a, "service");
        this.f6193h = c0635a;
    }
}
