package o2;

import I3.p;
import e1.k;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import n2.C0560c;
import n2.C0563f;
import n2.EnumC0562e;
import n2.EnumC0564g;
import r2.t;
import r2.u;
import w3.i;
import x2.AbstractC0720a;
import x3.AbstractC0728h;
import x3.AbstractC0730j;
import y1.AbstractC0752b;
import z3.EnumC0789a;

/* JADX INFO: renamed from: o2.d, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0584d extends AbstractC0582b {
    @Override // o2.AbstractC0582b
    public final Object a(B1.d dVar, p pVar, u uVar) {
        Object objInvoke;
        ByteBuffer byteBuffer = dVar.f115a;
        B1.b bVar = dVar.f116b;
        ByteBuffer byteBufferJ = AbstractC0752b.j(byteBuffer, bVar);
        int iRemaining = byteBufferJ.remaining();
        i iVar = i.f6729a;
        if (iRemaining >= 0) {
            ArrayList arrayList = new ArrayList();
            int i4 = iRemaining;
            while (i4 >= 255) {
                arrayList.add((byte) -1);
                i4 -= 255;
            }
            if (i4 > 0) {
                arrayList.add(Byte.valueOf((byte) i4));
            }
            byte[] bArrF0 = AbstractC0728h.f0(arrayList);
            int length = bArrF0.length + 2;
            byte[] bArr = new byte[length];
            bArr[0] = 127;
            bArr[1] = -32;
            System.arraycopy(bArrF0, 0, bArr, 2, bArrF0.length);
            byte[] bArr2 = new byte[iRemaining + length];
            byteBufferJ.get(bArr2, length, iRemaining);
            System.arraycopy(bArr, 0, bArr2, 0, length);
            short sA = this.f5967a.a();
            EnumC0564g enumC0564g = EnumC0564g.f5888d;
            ByteBuffer byteBufferWrap = ByteBuffer.wrap(bArr2);
            J3.i.d(byteBufferWrap, "wrap(...)");
            ArrayList<byte[]> arrayListA = AbstractC0720a.a(this.f5970d, this.f5969c.f(k.x(new C0563f(sA, true, enumC0564g, bVar.f110c, byteBufferWrap)), false));
            ArrayList arrayList2 = new ArrayList(AbstractC0730j.V(arrayListA));
            for (byte[] bArr3 : arrayListA) {
                EnumC0562e enumC0562e = EnumC0562e.f5876b;
                w2.b bVar2 = w2.b.f6713b;
                arrayList2.add(new C0560c(bArr3, enumC0562e, true));
            }
            if (!arrayList2.isEmpty() && (objInvoke = ((t) pVar).invoke(arrayList2, uVar)) == EnumC0789a.f6999a) {
                return objInvoke;
            }
        }
        return iVar;
    }

    @Override // o2.AbstractC0582b
    public final void b(boolean z4) {
    }
}
