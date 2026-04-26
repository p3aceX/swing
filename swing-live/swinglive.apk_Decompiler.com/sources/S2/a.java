package S2;

import B.k;
import D2.AbstractActivityC0029d;
import X.N;
import android.media.Image;
import android.media.ImageReader;
import android.os.Build;
import android.view.View;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.HashMap;

/* JADX INFO: loaded from: classes.dex */
public final class a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f1810a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Object f1811b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final Object f1812c;

    public a(int i4, AbstractActivityC0029d abstractActivityC0029d, k kVar) {
        this.f1811b = abstractActivityC0029d;
        this.f1810a = i4;
        this.f1812c = kVar;
        kVar.f104b = this;
    }

    public static ArrayList c(Image image) {
        ArrayList arrayList = new ArrayList();
        for (Image.Plane plane : image.getPlanes()) {
            ByteBuffer buffer = plane.getBuffer();
            int iRemaining = buffer.remaining();
            byte[] bArr = new byte[iRemaining];
            buffer.get(bArr, 0, iRemaining);
            HashMap map = new HashMap();
            map.put("bytesPerRow", Integer.valueOf(plane.getRowStride()));
            map.put("bytesPerPixel", Integer.valueOf(plane.getPixelStride()));
            map.put("bytes", bArr);
            arrayList.add(map);
        }
        return arrayList;
    }

    public int a() {
        if (Build.VERSION.SDK_INT < 35) {
            return 2;
        }
        AbstractActivityC0029d abstractActivityC0029d = (AbstractActivityC0029d) this.f1811b;
        int i4 = this.f1810a;
        View viewFindViewById = abstractActivityC0029d.findViewById(i4);
        if (viewFindViewById != null) {
            return viewFindViewById.getContentSensitivity();
        }
        throw new IllegalArgumentException(B1.a.l("FlutterView with ID ", i4, "not found"));
    }

    public ArrayList b(Image image) {
        ArrayList arrayList = new ArrayList();
        Image.Plane[] planes = image.getPlanes();
        int width = image.getWidth();
        int height = image.getHeight();
        ((N) this.f1812c).getClass();
        int i4 = width * height;
        byte[] bArr = new byte[((i4 / 4) * 2) + i4];
        ByteBuffer buffer = planes[1].getBuffer();
        ByteBuffer buffer2 = planes[2].getBuffer();
        int iPosition = buffer2.position();
        int iLimit = buffer.limit();
        buffer2.position(iPosition + 1);
        buffer.limit(iLimit - 1);
        int i5 = (i4 * 2) / 4;
        boolean z4 = buffer2.remaining() == i5 + (-2) && buffer2.compareTo(buffer) == 0;
        buffer2.position(iPosition);
        buffer.limit(iLimit);
        if (z4) {
            planes[0].getBuffer().get(bArr, 0, i4);
            ByteBuffer buffer3 = planes[1].getBuffer();
            planes[2].getBuffer().get(bArr, i4, 1);
            buffer3.get(bArr, i4 + 1, i5 - 1);
        } else {
            N.m(planes[0], width, height, bArr, 0, 1);
            N.m(planes[1], width, height, bArr, i4 + 1, 2);
            N.m(planes[2], width, height, bArr, i4, 2);
        }
        ByteBuffer byteBufferWrap = ByteBuffer.wrap(bArr);
        HashMap map = new HashMap();
        map.put("bytesPerRow", Integer.valueOf(image.getWidth()));
        map.put("bytesPerPixel", 1);
        map.put("bytes", byteBufferWrap.array());
        arrayList.add(map);
        return arrayList;
    }

    public void d(int i4) {
        if (Build.VERSION.SDK_INT < 35) {
            throw new IllegalStateException("isSupported() should be called before attempting to set content sensitivity as it is not supported on this device.");
        }
        AbstractActivityC0029d abstractActivityC0029d = (AbstractActivityC0029d) this.f1811b;
        int i5 = this.f1810a;
        View viewFindViewById = abstractActivityC0029d.findViewById(i5);
        if (viewFindViewById == null) {
            throw new IllegalArgumentException(B1.a.l("FlutterView with ID ", i5, "not found"));
        }
        if (viewFindViewById.getContentSensitivity() == i4) {
            return;
        }
        viewFindViewById.setContentSensitivity(i4);
        viewFindViewById.invalidate();
    }

    public a(int i4, int i5, int i6) {
        this.f1810a = i6;
        this.f1811b = ImageReader.newInstance(i4, i5, i6 == 17 ? 35 : i6, 1);
        this.f1812c = new N(17);
    }
}
