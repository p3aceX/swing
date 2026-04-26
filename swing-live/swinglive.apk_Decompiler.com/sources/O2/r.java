package O2;

import D2.v;
import android.util.Log;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;

/* JADX INFO: loaded from: classes.dex */
public final class r implements n {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final r f1458a;

    static {
        q qVar = q.f1455a;
        f1458a = new r();
    }

    @Override // O2.n
    public final ByteBuffer a(v vVar) {
        F3.a aVar = new F3.a();
        q qVar = q.f1455a;
        qVar.k(aVar, (String) vVar.f260b);
        qVar.k(aVar, vVar.f261c);
        ByteBuffer byteBufferAllocateDirect = ByteBuffer.allocateDirect(aVar.size());
        byteBufferAllocateDirect.put(aVar.a(), 0, aVar.size());
        return byteBufferAllocateDirect;
    }

    @Override // O2.n
    public final ByteBuffer b(Object obj) throws IOException {
        F3.a aVar = new F3.a();
        aVar.write(0);
        q.f1455a.k(aVar, obj);
        ByteBuffer byteBufferAllocateDirect = ByteBuffer.allocateDirect(aVar.size());
        byteBufferAllocateDirect.put(aVar.a(), 0, aVar.size());
        return byteBufferAllocateDirect;
    }

    @Override // O2.n
    public final v c(ByteBuffer byteBuffer) {
        byteBuffer.order(ByteOrder.nativeOrder());
        q qVar = q.f1455a;
        Object objE = qVar.e(byteBuffer);
        Object objE2 = qVar.e(byteBuffer);
        if (!(objE instanceof String) || byteBuffer.hasRemaining()) {
            throw new IllegalArgumentException("Method call corrupted");
        }
        return new v((String) objE, objE2, 15, false);
    }

    @Override // O2.n
    public final Object d(ByteBuffer byteBuffer) {
        byteBuffer.order(ByteOrder.nativeOrder());
        byte b5 = byteBuffer.get();
        if (b5 != 0) {
            if (b5 == 1) {
            }
            throw new IllegalArgumentException("Envelope corrupted");
        }
        Object objE = q.f1455a.e(byteBuffer);
        if (!byteBuffer.hasRemaining()) {
            return objE;
        }
        q qVar = q.f1455a;
        Object objE2 = qVar.e(byteBuffer);
        Object objE3 = qVar.e(byteBuffer);
        Object objE4 = qVar.e(byteBuffer);
        if ((objE2 instanceof String) && ((objE3 == null || (objE3 instanceof String)) && !byteBuffer.hasRemaining())) {
            throw new i(objE4, (String) objE2, (String) objE3);
        }
        throw new IllegalArgumentException("Envelope corrupted");
    }

    @Override // O2.n
    public final ByteBuffer e(String str, String str2) throws IOException {
        F3.a aVar = new F3.a();
        aVar.write(1);
        q qVar = q.f1455a;
        qVar.k(aVar, "error");
        qVar.k(aVar, str);
        aVar.write(0);
        qVar.k(aVar, str2);
        ByteBuffer byteBufferAllocateDirect = ByteBuffer.allocateDirect(aVar.size());
        byteBufferAllocateDirect.put(aVar.a(), 0, aVar.size());
        return byteBufferAllocateDirect;
    }

    @Override // O2.n
    public final ByteBuffer f(Object obj, String str, String str2) throws IOException {
        F3.a aVar = new F3.a();
        aVar.write(1);
        q qVar = q.f1455a;
        qVar.k(aVar, str);
        qVar.k(aVar, str2);
        if (obj instanceof Throwable) {
            qVar.k(aVar, Log.getStackTraceString((Throwable) obj));
        } else {
            qVar.k(aVar, obj);
        }
        ByteBuffer byteBufferAllocateDirect = ByteBuffer.allocateDirect(aVar.size());
        byteBufferAllocateDirect.put(aVar.a(), 0, aVar.size());
        return byteBufferAllocateDirect;
    }
}
