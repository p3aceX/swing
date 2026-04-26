package o2;

import I3.p;
import android.util.Log;
import e1.k;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.Iterator;
import n2.C0560c;
import n2.C0563f;
import n2.EnumC0559b;
import n2.EnumC0562e;
import n2.EnumC0564g;
import r2.u;
import w3.i;
import x2.AbstractC0720a;
import x3.AbstractC0726f;
import x3.AbstractC0730j;
import y1.AbstractC0752b;
import z3.EnumC0789a;

/* JADX INFO: renamed from: o2.c, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0583c extends AbstractC0582b {
    public final String e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public byte[] f5971f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public byte[] f5972g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public byte[] f5973h;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public EnumC0559b f5974i;

    public C0583c(int i4, p2.b bVar) {
        super(i4, bVar);
        this.e = "H26XPacket";
        this.f5974i = EnumC0559b.f5866c;
    }

    public static int c(ByteBuffer byteBuffer) {
        if (byteBuffer.get(0) == 0 && byteBuffer.get(1) == 0 && byteBuffer.get(2) == 0 && byteBuffer.get(3) == 1) {
            return 4;
        }
        return (byteBuffer.get(0) == 0 && byteBuffer.get(1) == 0 && byteBuffer.get(2) == 1) ? 3 : 0;
    }

    public static byte[] d(ByteBuffer byteBuffer) {
        byteBuffer.rewind();
        if (c(byteBuffer) != 0) {
            return AbstractC0752b.l(byteBuffer);
        }
        ByteBuffer byteBufferAllocate = ByteBuffer.allocate(byteBuffer.remaining() + 4);
        byteBufferAllocate.putInt(1);
        byteBufferAllocate.put(byteBuffer);
        return AbstractC0752b.l(byteBufferAllocate);
    }

    @Override // o2.AbstractC0582b
    public final Object a(B1.d dVar, p pVar, u uVar) {
        Object next;
        Object objInvoke;
        ByteBuffer byteBuffer = dVar.f115a;
        B1.b bVar = dVar.f116b;
        ByteBuffer byteBufferJ = AbstractC0752b.j(byteBuffer, bVar);
        int iRemaining = byteBufferJ.remaining();
        i iVar = i.f6729a;
        if (iRemaining >= 0) {
            EnumC0559b enumC0559b = this.f5974i;
            EnumC0559b enumC0559b2 = EnumC0559b.f5867d;
            String str = this.e;
            if (enumC0559b == enumC0559b2) {
                byte[] bArr = this.f5971f;
                byte[] bArr2 = this.f5972g;
                byte[] bArr3 = this.f5973h;
                if (bArr == null || bArr2 == null || bArr3 == null) {
                    Log.e(str, "waiting for a valid sps, pps and vps");
                    return iVar;
                }
            } else {
                byte[] bArr4 = this.f5971f;
                byte[] bArr5 = this.f5972g;
                if (bArr4 == null || bArr5 == null) {
                    Log.e(str, "waiting for a valid sps and pps");
                    return iVar;
                }
            }
            boolean z4 = bVar.f111d;
            if (z4) {
                byte[] bArr6 = this.f5973h;
                if (bArr6 == null) {
                    bArr6 = new byte[0];
                }
                byte[] bArr7 = this.f5971f;
                if (bArr7 == null) {
                    bArr7 = new byte[0];
                }
                byte[] bArr8 = this.f5972g;
                if (bArr8 == null) {
                    bArr8 = new byte[0];
                }
                if (!(bArr6.length == 0) && AbstractC0720a.b(bArr6, byteBufferJ)) {
                    byteBufferJ.position(bArr6.length);
                    byteBufferJ = byteBufferJ.slice();
                    J3.i.d(byteBufferJ, "slice(...)");
                }
                if (bArr7.length != 0 && AbstractC0720a.b(bArr7, byteBufferJ)) {
                    byteBufferJ.position(bArr7.length);
                    byteBufferJ = byteBufferJ.slice();
                    J3.i.d(byteBufferJ, "slice(...)");
                }
                if (bArr8.length != 0 && AbstractC0720a.b(bArr8, byteBufferJ)) {
                    byteBufferJ.position(bArr8.length);
                    byteBufferJ = byteBufferJ.slice();
                    J3.i.d(byteBufferJ, "slice(...)");
                }
                byteBufferJ.rewind();
            } else {
                byteBufferJ.rewind();
            }
            if (c(byteBufferJ) == 0) {
                ByteBuffer byteBufferAllocate = ByteBuffer.allocate(byteBufferJ.remaining() + 4);
                byteBufferAllocate.putInt(1);
                byteBufferAllocate.put(byteBufferJ);
                byteBufferJ = byteBufferAllocate;
            }
            if (z4) {
                byte[] bArr9 = this.f5973h;
                if (bArr9 == null) {
                    bArr9 = new byte[0];
                }
                byte[] bArr10 = this.f5971f;
                if (bArr10 == null) {
                    bArr10 = new byte[0];
                }
                byte[] bArr11 = this.f5972g;
                if (bArr11 == null) {
                    bArr11 = new byte[0];
                }
                EnumC0559b enumC0559b3 = this.f5974i;
                EnumC0559b enumC0559b4 = EnumC0559b.f5866c;
                int i4 = enumC0559b3 == enumC0559b4 ? 6 : 7;
                byte[] bArrJ0 = AbstractC0726f.j0(AbstractC0726f.j0(bArr9, bArr10), bArr11);
                ByteBuffer byteBufferAllocate2 = ByteBuffer.allocate(byteBufferJ.remaining() + i4 + bArrJ0.length);
                byteBufferAllocate2.putInt(1);
                if (this.f5974i == enumC0559b4) {
                    byteBufferAllocate2.put((byte) 9);
                    byteBufferAllocate2.put((byte) -16);
                } else {
                    byteBufferAllocate2.put((byte) 70);
                    byteBufferAllocate2.put((byte) 1);
                    byteBufferAllocate2.put((byte) 80);
                }
                byteBufferAllocate2.put(bArrJ0);
                byteBufferAllocate2.put(AbstractC0752b.l(byteBufferJ));
                byteBufferAllocate2.rewind();
                byteBufferJ = byteBufferAllocate2;
            } else {
                byteBufferJ.rewind();
            }
            byte[] bArr12 = new byte[byteBufferJ.remaining()];
            byteBufferJ.get(bArr12, 0, byteBufferJ.remaining());
            Iterator it = this.f5967a.f6194a.f6263f.iterator();
            while (true) {
                if (!it.hasNext()) {
                    next = null;
                    break;
                }
                next = it.next();
                EnumC0559b enumC0559b5 = ((q2.b) next).f6265a;
                if (enumC0559b5 != EnumC0559b.f5865b && enumC0559b5 != EnumC0559b.e) {
                    break;
                }
            }
            q2.b bVar2 = (q2.b) next;
            short s4 = bVar2 != null ? bVar2.f6266b : (short) 0;
            EnumC0564g enumC0564g = EnumC0564g.f5887c;
            ByteBuffer byteBufferWrap = ByteBuffer.wrap(bArr12);
            J3.i.d(byteBufferWrap, "wrap(...)");
            ArrayList<byte[]> arrayListA = AbstractC0720a.a(this.f5970d, this.f5969c.f(k.x(new C0563f(s4, z4, enumC0564g, bVar.f110c, byteBufferWrap)), false));
            ArrayList arrayList = new ArrayList(AbstractC0730j.V(arrayListA));
            for (byte[] bArr13 : arrayListA) {
                EnumC0562e enumC0562e = EnumC0562e.f5875a;
                w2.b bVar3 = w2.b.f6713b;
                arrayList.add(new C0560c(bArr13, enumC0562e, z4));
            }
            if (!arrayList.isEmpty() && (objInvoke = pVar.invoke(arrayList, uVar)) == EnumC0789a.f6999a) {
                return objInvoke;
            }
        }
        return iVar;
    }

    @Override // o2.AbstractC0582b
    public final void b(boolean z4) {
        if (z4) {
            this.f5973h = null;
            this.f5971f = null;
            this.f5972g = null;
        }
    }
}
