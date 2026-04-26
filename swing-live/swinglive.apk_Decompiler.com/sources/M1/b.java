package M1;

import I3.l;
import K.k;
import O.RunnableC0093d;
import Y0.n;
import android.hardware.camera2.CameraCaptureSession;
import android.util.Log;
import com.swing.live.MainActivity;
import io.ktor.network.sockets.A;
import java.nio.ByteBuffer;
import java.security.MessageDigest;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import o3.C0588D;
import o3.C0592H;
import o3.C0594b;
import o3.V;
import o3.W;
import p3.C0618a;
import q3.AbstractC0639d;
import q3.AbstractC0641f;
import q3.AbstractC0643h;
import q3.C0637b;
import q3.EnumC0638c;
import q3.EnumC0640e;
import q3.EnumC0645j;
import u3.AbstractC0692a;
import w3.i;
import x3.AbstractC0723c;

/* JADX INFO: loaded from: classes.dex */
public final /* synthetic */ class b implements l {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f1063a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ Object f1064b;

    public /* synthetic */ b(Object obj, int i4) {
        this.f1063a = i4;
        this.f1064b = obj;
    }

    @Override // I3.l
    public final Object invoke(Object obj) {
        int iA = 0;
        i iVar = i.f6729a;
        Object obj2 = this.f1064b;
        switch (this.f1063a) {
            case 0:
                CameraCaptureSession cameraCaptureSession = (CameraCaptureSession) obj;
                J3.i.e(cameraCaptureSession, "it");
                cameraCaptureSession.close();
                e eVar = (e) obj2;
                eVar.getClass();
                Log.e(eVar.f1069a, "Configuration failed");
                return iVar;
            case 1:
                ((A) obj2).i();
                return iVar;
            case 2:
                Z3.h hVar = (Z3.h) obj;
                J3.i.e(hVar, "handshakes");
                MessageDigest messageDigest = MessageDigest.getInstance((String) obj2);
                J3.i.b(messageDigest);
                ByteBuffer byteBuffer = (ByteBuffer) io.ktor.network.util.a.f4944a.a();
                while (!hVar.w()) {
                    try {
                        int iRemaining = byteBuffer.remaining();
                        Z3.i.c(hVar, byteBuffer);
                        if (iRemaining - byteBuffer.remaining() == -1) {
                            byte[] bArrDigest = messageDigest.digest();
                            io.ktor.network.util.a.f4944a.d(byteBuffer);
                            return bArrDigest;
                        }
                        byteBuffer.flip();
                        messageDigest.update(byteBuffer);
                        byteBuffer.clear();
                    } catch (Throwable th) {
                        io.ktor.network.util.a.f4944a.d(byteBuffer);
                        throw th;
                    }
                }
                byte[] bArrDigest2 = messageDigest.digest();
                io.ktor.network.util.a.f4944a.d(byteBuffer);
                return bArrDigest2;
            case 3:
                Z3.a aVar = (Z3.a) obj;
                J3.i.e(aVar, "$this$sendHandshakeRecord");
                C0592H c0592h = W.f6061b;
                C0588D c0588d = (C0588D) obj2;
                ArrayList arrayList = (ArrayList) c0588d.f5986a.e;
                J3.i.e(arrayList, "suites");
                byte[] bArr = c0588d.e;
                J3.i.e(bArr, "random");
                aVar.o((short) 771);
                AbstractC0692a.c(aVar, bArr, 0, bArr.length);
                aVar.n((byte) 32);
                AbstractC0692a.c(aVar, new byte[32], 0, 32);
                aVar.o((short) (arrayList.size() * 2));
                Iterator it = arrayList.iterator();
                while (it.hasNext()) {
                    aVar.o(((C0594b) it.next()).f6066a);
                }
                aVar.n((byte) 1);
                aVar.n((byte) 0);
                ArrayList arrayList2 = new ArrayList();
                List<C0637b> list = AbstractC0643h.f6297a;
                Z3.a aVar2 = new Z3.a();
                C0592H c0592h2 = EnumC0645j.f6300b;
                aVar2.o((short) 13);
                int size = list.size() * 2;
                aVar2.o((short) (size + 2));
                aVar2.o((short) size);
                for (C0637b c0637b : list) {
                    aVar2.n(c0637b.f6276a.f6273a);
                    aVar2.n(c0637b.f6277b.f6296a);
                }
                arrayList2.add(aVar2);
                List list2 = AbstractC0639d.f6286a;
                Z3.a aVar3 = new Z3.a();
                if (list2.size() > 16382) {
                    throw new IllegalArgumentException("Too many named curves provided: at most 16382 could be provided");
                }
                C0592H c0592h3 = EnumC0645j.f6300b;
                aVar3.o((short) 10);
                int size2 = list2.size() * 2;
                aVar3.o((short) (size2 + 2));
                aVar3.o((short) size2);
                Iterator it2 = list2.iterator();
                while (it2.hasNext()) {
                    aVar3.o(((EnumC0638c) it2.next()).f6284a);
                }
                arrayList2.add(aVar3);
                List list3 = AbstractC0641f.f6291a;
                Z3.a aVar4 = new Z3.a();
                C0592H c0592h4 = EnumC0645j.f6300b;
                aVar4.o((short) 11);
                int size3 = list3.size();
                aVar4.o((short) (1 + size3));
                aVar4.n((byte) size3);
                Iterator it3 = list3.iterator();
                while (it3.hasNext()) {
                    aVar4.n(((EnumC0640e) it3.next()).f6290a);
                }
                arrayList2.add(aVar4);
                Iterator it4 = arrayList2.iterator();
                while (it4.hasNext()) {
                    iA += (int) AbstractC0692a.a((Z3.h) it4.next());
                }
                aVar.o((short) iA);
                Iterator it5 = arrayList2.iterator();
                J3.i.d(it5, "iterator(...)");
                while (it5.hasNext()) {
                    Object next = it5.next();
                    J3.i.d(next, "next(...)");
                    AbstractC0692a.d(aVar, (Z3.h) next);
                }
                return iVar;
            case 4:
                ((V) obj2).f6059b.close();
                return iVar;
            case 5:
                Z3.a aVar5 = (Z3.a) obj;
                J3.i.e(aVar5, "$this$cipherLoop");
                byte[] iv = ((C0618a) obj2).f6200c.getIV();
                J3.i.d(iv, "getIV(...)");
                AbstractC0692a.c(aVar5, iv, 0, iv.length);
                return iVar;
            case k.STRING_SET_FIELD_NUMBER /* 6 */:
                return obj == ((AbstractC0723c) obj2) ? "(this Collection)" : String.valueOf(obj);
            case k.DOUBLE_FIELD_NUMBER /* 7 */:
                y2.l lVar = (y2.l) obj;
                J3.i.e(lVar, "stats");
                b bVar = ((y2.k) obj2).f6918f;
                if (bVar != null) {
                    bVar.invoke(lVar);
                }
                return iVar;
            default:
                y2.l lVar2 = (y2.l) obj;
                J3.i.e(lVar2, "stats");
                n nVar = (n) obj2;
                ((MainActivity) nVar.f2488a).runOnUiThread(new RunnableC0093d(15, nVar, lVar2));
                return iVar;
        }
    }
}
