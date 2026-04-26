package t;

import android.content.Context;
import android.graphics.Typeface;
import android.net.Uri;
import android.util.Log;
import e1.AbstractC0367g;
import java.lang.reflect.Array;
import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.nio.ByteBuffer;
import java.util.List;
import n.k;
import x.C0710g;

/* JADX INFO: loaded from: classes.dex */
public final class f extends AbstractC0367g {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final Class f6520c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final Constructor f6521d;
    public static final Method e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final Method f6522f;

    static {
        Class<?> cls;
        Constructor<?> constructor;
        Method method;
        Method method2;
        try {
            cls = Class.forName("android.graphics.FontFamily");
            constructor = cls.getConstructor(new Class[0]);
            Class cls2 = Integer.TYPE;
            method = cls.getMethod("addFontWeightStyle", ByteBuffer.class, cls2, List.class, cls2, Boolean.TYPE);
            method2 = Typeface.class.getMethod("createFromFamiliesWithDefault", Array.newInstance(cls, 1).getClass());
        } catch (ClassNotFoundException | NoSuchMethodException e4) {
            Log.e("TypefaceCompatApi24Impl", e4.getClass().getName(), e4);
            cls = null;
            constructor = null;
            method = null;
            method2 = null;
        }
        f6521d = constructor;
        f6520c = cls;
        e = method;
        f6522f = method2;
    }

    public static boolean c0(Object obj, ByteBuffer byteBuffer, int i4, int i5, boolean z4) {
        try {
            return ((Boolean) e.invoke(obj, byteBuffer, Integer.valueOf(i4), null, Integer.valueOf(i5), Boolean.valueOf(z4))).booleanValue();
        } catch (IllegalAccessException | InvocationTargetException unused) {
            return false;
        }
    }

    public static Typeface d0(Object obj) {
        try {
            Object objNewInstance = Array.newInstance((Class<?>) f6520c, 1);
            Array.set(objNewInstance, 0, obj);
            return (Typeface) f6522f.invoke(null, objNewInstance);
        } catch (IllegalAccessException | InvocationTargetException unused) {
            return null;
        }
    }

    /* JADX WARN: Removed duplicated region for block: B:33:0x005c  */
    /* JADX WARN: Removed duplicated region for block: B:54:0x0068 A[SYNTHETIC] */
    @Override // e1.AbstractC0367g
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final android.graphics.Typeface i(android.content.Context r17, s.f r18, android.content.res.Resources r19, int r20) {
        /*
            r16 = this;
            r1 = 0
            r0 = 0
            java.lang.reflect.Constructor r2 = t.f.f6521d     // Catch: java.lang.Throwable -> Lb
            java.lang.Object[] r3 = new java.lang.Object[r0]     // Catch: java.lang.Throwable -> Lb
            java.lang.Object r2 = r2.newInstance(r3)     // Catch: java.lang.Throwable -> Lb
            goto Lc
        Lb:
            r2 = r1
        Lc:
            if (r2 != 0) goto Lf
            goto L68
        Lf:
            r3 = r18
            s.g[] r3 = r3.f6443a
            int r4 = r3.length
            r5 = r0
        L15:
            if (r5 >= r4) goto L71
            r6 = r3[r5]
            int r0 = r6.f6448f
            java.io.File r7 = e1.k.v(r17)
            if (r7 != 0) goto L25
            r8 = r19
        L23:
            r0 = r1
            goto L59
        L25:
            r8 = r19
            boolean r0 = e1.k.j(r7, r8, r0)     // Catch: java.lang.Throwable -> L6c
            if (r0 != 0) goto L31
            r7.delete()
            goto L23
        L31:
            java.io.FileInputStream r9 = new java.io.FileInputStream     // Catch: java.io.IOException -> L55 java.lang.Throwable -> L6c
            r9.<init>(r7)     // Catch: java.io.IOException -> L55 java.lang.Throwable -> L6c
            java.nio.channels.FileChannel r10 = r9.getChannel()     // Catch: java.lang.Throwable -> L4a
            long r14 = r10.size()     // Catch: java.lang.Throwable -> L4a
            java.nio.channels.FileChannel$MapMode r11 = java.nio.channels.FileChannel.MapMode.READ_ONLY     // Catch: java.lang.Throwable -> L4a
            r12 = 0
            java.nio.MappedByteBuffer r0 = r10.map(r11, r12, r14)     // Catch: java.lang.Throwable -> L4a
            r9.close()     // Catch: java.io.IOException -> L55 java.lang.Throwable -> L6c
            goto L56
        L4a:
            r0 = move-exception
            r10 = r0
            r9.close()     // Catch: java.lang.Throwable -> L50
            goto L54
        L50:
            r0 = move-exception
            r10.addSuppressed(r0)     // Catch: java.io.IOException -> L55 java.lang.Throwable -> L6c
        L54:
            throw r10     // Catch: java.io.IOException -> L55 java.lang.Throwable -> L6c
        L55:
            r0 = r1
        L56:
            r7.delete()
        L59:
            if (r0 != 0) goto L5c
            goto L68
        L5c:
            int r7 = r6.f6445b
            boolean r9 = r6.f6446c
            int r6 = r6.e
            boolean r0 = c0(r2, r0, r6, r7, r9)
            if (r0 != 0) goto L69
        L68:
            return r1
        L69:
            int r5 = r5 + 1
            goto L15
        L6c:
            r0 = move-exception
            r7.delete()
            throw r0
        L71:
            android.graphics.Typeface r0 = d0(r2)
            return r0
        */
        throw new UnsupportedOperationException("Method not decompiled: t.f.i(android.content.Context, s.f, android.content.res.Resources, int):android.graphics.Typeface");
    }

    @Override // e1.AbstractC0367g
    public final Typeface j(Context context, C0710g[] c0710gArr, int i4) {
        Object objNewInstance;
        int i5 = 0;
        try {
            objNewInstance = f6521d.newInstance(new Object[0]);
        } catch (IllegalAccessException | InstantiationException | InvocationTargetException unused) {
            objNewInstance = null;
        }
        if (objNewInstance != null) {
            k kVar = new k();
            int length = c0710gArr.length;
            while (true) {
                if (i5 >= length) {
                    Typeface typefaceD0 = d0(objNewInstance);
                    if (typefaceD0 != null) {
                        return Typeface.create(typefaceD0, i4);
                    }
                } else {
                    C0710g c0710g = c0710gArr[i5];
                    Uri uri = c0710g.f6743a;
                    ByteBuffer byteBufferY = (ByteBuffer) kVar.getOrDefault(uri, null);
                    if (byteBufferY == null) {
                        byteBufferY = e1.k.y(context, uri);
                        kVar.put(uri, byteBufferY);
                    }
                    if (byteBufferY == null) {
                        break;
                    }
                    if (!c0(objNewInstance, byteBufferY, c0710g.f6744b, c0710g.f6745c, c0710g.f6746d)) {
                        break;
                    }
                    i5++;
                }
            }
        }
        return null;
    }
}
