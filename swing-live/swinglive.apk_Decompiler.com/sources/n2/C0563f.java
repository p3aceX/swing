package n2;

import java.nio.ByteBuffer;

/* JADX INFO: renamed from: n2.f, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0563f extends AbstractC0561d {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final EnumC0564g f5879c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final long f5880d;
    public final ByteBuffer e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final int f5881f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public final int f5882g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public final boolean f5883h;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public final int f5884i;

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public final int f5885j;

    public C0563f(int i4, boolean z4, EnumC0564g enumC0564g, long j4, ByteBuffer byteBuffer) {
        super(i4, z4);
        this.f5879c = enumC0564g;
        this.f5880d = j4;
        this.e = byteBuffer;
        this.f5881f = byteBuffer.remaining() + 14;
        this.f5882g = 2;
        this.f5883h = true;
        this.f5884i = 2;
        this.f5885j = 5;
    }
}
