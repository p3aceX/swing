package b2;

import I3.p;
import a2.EnumC0188a;
import java.nio.ByteBuffer;
import w3.i;
import y1.AbstractC0752b;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class d extends H0.a {

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public boolean f3284j;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public final byte[] f3283i = new byte[5];

    /* JADX INFO: renamed from: k, reason: collision with root package name */
    public int f3285k = 48000;

    @Override // H0.a
    public final void a0(boolean z4) {
        this.f3284j = false;
    }

    @Override // H0.a
    public final Object l(B1.d dVar, p pVar, InterfaceC0762c interfaceC0762c) {
        byte[] bArr;
        ByteBuffer byteBuffer = dVar.f115a;
        B1.b bVar = dVar.f116b;
        ByteBuffer byteBufferJ = AbstractC0752b.j(byteBuffer, bVar);
        long j4 = bVar.f110c / ((long) 1000);
        EnumC0188a[] enumC0188aArr = EnumC0188a.f2633a;
        byte[] bArr2 = this.f3283i;
        bArr2[1] = (byte) 79;
        bArr2[2] = (byte) 20336;
        bArr2[3] = (byte) 5206133;
        bArr2[4] = (byte) 1332770163;
        if (this.f3284j) {
            a2.b[] bVarArr = a2.b.f2634a;
            bArr2[0] = (byte) 145;
            bArr = new byte[byteBufferJ.remaining() + bArr2.length];
            byteBufferJ.get(bArr, bArr2.length, byteBufferJ.remaining());
        } else {
            a2.b[] bVarArr2 = a2.b.f2634a;
            bArr2[0] = (byte) 144;
            int i4 = this.f3285k;
            bArr = new byte[19 + bArr2.length];
            int length = bArr2.length;
            bArr[length] = 79;
            bArr[length + 1] = 112;
            bArr[length + 2] = 117;
            bArr[3 + length] = 115;
            bArr[4 + length] = 72;
            bArr[length + 5] = 101;
            bArr[length + 6] = 97;
            bArr[length + 7] = 100;
            bArr[length + 8] = 1;
            bArr[length + 9] = (byte) 2;
            bArr[length + 10] = (byte) 15;
            bArr[length + 11] = (byte) 3840;
            bArr[length + 12] = (byte) 0;
            bArr[length + 13] = (byte) 0;
            bArr[length + 14] = (byte) (i4 >> 8);
            bArr[15 + length] = (byte) i4;
            byte b5 = (byte) 0;
            bArr[length + 16] = b5;
            bArr[length + 17] = b5;
            bArr[length + 18] = b5;
            this.f3284j = true;
        }
        byte[] bArr3 = bArr;
        System.arraycopy(bArr2, 0, bArr3, 0, bArr2.length);
        Object objInvoke = pVar.invoke(new Z1.a(bArr3, j4, bArr3.length, Z1.b.f2597a), interfaceC0762c);
        return objInvoke == EnumC0789a.f6999a ? objInvoke : i.f6729a;
    }
}
