package v3;

import J3.i;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;

/* JADX INFO: renamed from: v3.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0695a extends AbstractC0696b {

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final /* synthetic */ int f6672f = 0;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final int f6673m;

    public C0695a() {
        super(128);
        this.f6673m = 65536;
    }

    @Override // v3.AbstractC0696b
    public final Object b(Object obj) {
        switch (this.f6672f) {
            case 0:
                ByteBuffer byteBuffer = (ByteBuffer) obj;
                byteBuffer.clear();
                byteBuffer.order(ByteOrder.BIG_ENDIAN);
                return byteBuffer;
            default:
                ByteBuffer byteBuffer2 = (ByteBuffer) obj;
                byteBuffer2.clear();
                byteBuffer2.order(ByteOrder.BIG_ENDIAN);
                return byteBuffer2;
        }
    }

    @Override // v3.AbstractC0696b
    public final ByteBuffer c() {
        switch (this.f6672f) {
            case 0:
                ByteBuffer byteBufferAllocate = ByteBuffer.allocate(this.f6673m);
                i.b(byteBufferAllocate);
                return byteBufferAllocate;
            default:
                ByteBuffer byteBufferAllocateDirect = ByteBuffer.allocateDirect(this.f6673m);
                i.b(byteBufferAllocateDirect);
                return byteBufferAllocateDirect;
        }
    }

    @Override // v3.AbstractC0696b
    public final void g(Object obj) {
        switch (this.f6672f) {
            case 0:
                ByteBuffer byteBuffer = (ByteBuffer) obj;
                i.e(byteBuffer, "instance");
                if (byteBuffer.capacity() != this.f6673m) {
                    throw new IllegalStateException("Check failed.");
                }
                if (byteBuffer.isDirect()) {
                    throw new IllegalStateException("Check failed.");
                }
                return;
            default:
                ByteBuffer byteBuffer2 = (ByteBuffer) obj;
                i.e(byteBuffer2, "instance");
                if (byteBuffer2.capacity() != this.f6673m) {
                    throw new IllegalStateException("Check failed.");
                }
                if (!byteBuffer2.isDirect()) {
                    throw new IllegalStateException("Check failed.");
                }
                return;
        }
    }

    public C0695a(int i4, int i5) {
        super(i4);
        this.f6673m = i5;
    }
}
