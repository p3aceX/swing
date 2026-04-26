package H2;

import E2.i;
import a.AbstractC0184a;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import java.nio.ByteBuffer;
import u1.C0690c;

/* JADX INFO: loaded from: classes.dex */
public final class b extends C0690c {
    public final /* synthetic */ int e;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public /* synthetic */ b(i iVar, int i4) {
        super(iVar, 5);
        this.e = i4;
    }

    @Override // u1.C0690c
    public final Bitmap u(ByteBuffer byteBuffer, d dVar) {
        switch (this.e) {
            case 0:
                Bitmap bitmapU = super.u(byteBuffer, dVar);
                if (bitmapU != null) {
                    return bitmapU;
                }
                int iRemaining = byteBuffer.remaining();
                byte[] bArr = new byte[iRemaining];
                byteBuffer.get(bArr);
                byteBuffer.rewind();
                BitmapFactory.Options options = new BitmapFactory.Options();
                options.inPreferredConfig = Bitmap.Config.ARGB_8888;
                Bitmap bitmapDecodeByteArray = BitmapFactory.decodeByteArray(bArr, 0, iRemaining, options);
                if (dVar.f531c == 0) {
                    return AbstractC0184a.h(bitmapDecodeByteArray, dVar.e);
                }
                Matrix matrix = new Matrix();
                matrix.postRotate(dVar.f531c);
                Bitmap bitmapCreateBitmap = Bitmap.createBitmap(bitmapDecodeByteArray, 0, 0, bitmapDecodeByteArray.getWidth(), bitmapDecodeByteArray.getHeight(), matrix, true);
                bitmapDecodeByteArray.recycle();
                return AbstractC0184a.h(bitmapCreateBitmap, dVar.e);
            default:
                return AbstractC0184a.h(super.u(byteBuffer, dVar), dVar.e);
        }
    }
}
