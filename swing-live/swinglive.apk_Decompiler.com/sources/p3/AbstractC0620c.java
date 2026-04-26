package p3;

import I3.l;
import J3.i;
import Z3.h;
import java.nio.ByteBuffer;
import javax.crypto.Cipher;
import u3.AbstractC0692a;
import v3.C0695a;

/* JADX INFO: renamed from: p3.c, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0620c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final C0695a f6208a = new C0695a();

    public static final Z3.a a(h hVar, Cipher cipher, l lVar) {
        int iRemaining;
        i.e(hVar, "<this>");
        i.e(cipher, "cipher");
        ByteBuffer byteBuffer = (ByteBuffer) io.ktor.network.util.a.f4944a.a();
        C0695a c0695a = f6208a;
        Object objA = c0695a.a();
        boolean z4 = true;
        try {
            Z3.a aVar = new Z3.a();
            byteBuffer.clear();
            lVar.invoke(aVar);
            while (true) {
                if (byteBuffer.hasRemaining()) {
                    int iRemaining2 = byteBuffer.remaining();
                    Z3.i.c(hVar, byteBuffer);
                    iRemaining = iRemaining2 - byteBuffer.remaining();
                } else {
                    iRemaining = 0;
                }
                byteBuffer.flip();
                if (!byteBuffer.hasRemaining() && (iRemaining == -1 || hVar.w())) {
                    break;
                }
                ((ByteBuffer) objA).clear();
                if (cipher.getOutputSize(byteBuffer.remaining()) > ((ByteBuffer) objA).remaining()) {
                    if (z4) {
                        c0695a.d(objA);
                    }
                    ByteBuffer byteBufferAllocate = ByteBuffer.allocate(cipher.getOutputSize(byteBuffer.remaining()));
                    i.d(byteBufferAllocate, "allocate(...)");
                    objA = byteBufferAllocate;
                    z4 = false;
                }
                cipher.update(byteBuffer, (ByteBuffer) objA);
                ((ByteBuffer) objA).flip();
                ByteBuffer byteBuffer2 = (ByteBuffer) objA;
                i.e(byteBuffer2, "buffer");
                Z3.i.g(aVar, byteBuffer2);
                byteBuffer.compact();
            }
            byteBuffer.hasRemaining();
            ((ByteBuffer) objA).hasRemaining();
            int outputSize = cipher.getOutputSize(0);
            if (outputSize != 0) {
                if (outputSize > ((ByteBuffer) objA).capacity()) {
                    byte[] bArrDoFinal = cipher.doFinal();
                    i.d(bArrDoFinal, "doFinal(...)");
                    AbstractC0692a.c(aVar, bArrDoFinal, 0, bArrDoFinal.length);
                } else {
                    ((ByteBuffer) objA).clear();
                    cipher.doFinal(AbstractC0619b.f6207a, (ByteBuffer) objA);
                    ((ByteBuffer) objA).flip();
                    if (((ByteBuffer) objA).hasRemaining()) {
                        ByteBuffer byteBuffer3 = (ByteBuffer) objA;
                        i.e(byteBuffer3, "buffer");
                        Z3.i.g(aVar, byteBuffer3);
                    } else {
                        byte[] bArrDoFinal2 = cipher.doFinal();
                        i.d(bArrDoFinal2, "doFinal(...)");
                        AbstractC0692a.c(aVar, bArrDoFinal2, 0, bArrDoFinal2.length);
                    }
                }
            }
            io.ktor.network.util.a.f4944a.d(byteBuffer);
            if (z4) {
                c0695a.d(objA);
            }
            return aVar;
        } catch (Throwable th) {
            io.ktor.network.util.a.f4944a.d(byteBuffer);
            if (1 != 0) {
                c0695a.d(objA);
            }
            throw th;
        }
    }
}
