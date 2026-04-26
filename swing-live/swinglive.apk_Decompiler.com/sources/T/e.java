package t;

import android.content.Context;
import android.content.res.Resources;
import android.graphics.Typeface;
import android.os.ParcelFileDescriptor;
import android.system.ErrnoException;
import android.system.Os;
import android.system.OsConstants;
import android.util.Log;
import e1.AbstractC0367g;
import e1.k;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.lang.reflect.Array;
import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import x.C0710g;

/* JADX INFO: loaded from: classes.dex */
public class e extends AbstractC0367g {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static Class f6516c = null;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static Constructor f6517d = null;
    public static Method e = null;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static Method f6518f = null;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public static boolean f6519g = false;

    public static boolean c0(Object obj, String str, int i4, boolean z4) {
        d0();
        try {
            return ((Boolean) e.invoke(obj, str, Integer.valueOf(i4), Boolean.valueOf(z4))).booleanValue();
        } catch (IllegalAccessException | InvocationTargetException e4) {
            throw new RuntimeException(e4);
        }
    }

    public static void d0() {
        Class<?> cls;
        Method method;
        Constructor<?> constructor;
        Method method2;
        if (f6519g) {
            return;
        }
        f6519g = true;
        try {
            cls = Class.forName("android.graphics.FontFamily");
            constructor = cls.getConstructor(new Class[0]);
            method2 = cls.getMethod("addFontWeightStyle", String.class, Integer.TYPE, Boolean.TYPE);
            method = Typeface.class.getMethod("createFromFamiliesWithDefault", Array.newInstance(cls, 1).getClass());
        } catch (ClassNotFoundException | NoSuchMethodException e4) {
            Log.e("TypefaceCompatApi21Impl", e4.getClass().getName(), e4);
            cls = null;
            method = null;
            constructor = null;
            method2 = null;
        }
        f6517d = constructor;
        f6516c = cls;
        e = method2;
        f6518f = method;
    }

    @Override // e1.AbstractC0367g
    public Typeface i(Context context, s.f fVar, Resources resources, int i4) {
        d0();
        try {
            Object objNewInstance = f6517d.newInstance(new Object[0]);
            for (s.g gVar : fVar.f6443a) {
                File fileV = k.v(context);
                if (fileV == null) {
                    return null;
                }
                try {
                    if (!k.j(fileV, resources, gVar.f6448f)) {
                        return null;
                    }
                    if (!c0(objNewInstance, fileV.getPath(), gVar.f6445b, gVar.f6446c)) {
                        return null;
                    }
                    fileV.delete();
                } catch (RuntimeException unused) {
                    return null;
                } finally {
                    fileV.delete();
                }
            }
            d0();
            try {
                Object objNewInstance2 = Array.newInstance((Class<?>) f6516c, 1);
                Array.set(objNewInstance2, 0, objNewInstance);
                return (Typeface) f6518f.invoke(null, objNewInstance2);
            } catch (IllegalAccessException | InvocationTargetException e4) {
                throw new RuntimeException(e4);
            }
        } catch (IllegalAccessException | InstantiationException | InvocationTargetException e5) {
            throw new RuntimeException(e5);
        }
    }

    @Override // e1.AbstractC0367g
    public Typeface j(Context context, C0710g[] c0710gArr, int i4) {
        String str;
        if (c0710gArr.length >= 1) {
            try {
                ParcelFileDescriptor parcelFileDescriptorOpenFileDescriptor = context.getContentResolver().openFileDescriptor(r(c0710gArr, i4).f6743a, "r", null);
                if (parcelFileDescriptorOpenFileDescriptor != null) {
                    try {
                        try {
                            str = Os.readlink("/proc/self/fd/" + parcelFileDescriptorOpenFileDescriptor.getFd());
                        } finally {
                        }
                    } catch (ErrnoException unused) {
                    }
                    File file = OsConstants.S_ISREG(Os.stat(str).st_mode) ? new File(str) : null;
                    if (file != null && file.canRead()) {
                        Typeface typefaceCreateFromFile = Typeface.createFromFile(file);
                        parcelFileDescriptorOpenFileDescriptor.close();
                        return typefaceCreateFromFile;
                    }
                    FileInputStream fileInputStream = new FileInputStream(parcelFileDescriptorOpenFileDescriptor.getFileDescriptor());
                    try {
                        Typeface typefaceK = k(context, fileInputStream);
                        fileInputStream.close();
                        parcelFileDescriptorOpenFileDescriptor.close();
                        return typefaceK;
                    } finally {
                    }
                }
                if (parcelFileDescriptorOpenFileDescriptor != null) {
                    parcelFileDescriptorOpenFileDescriptor.close();
                    return null;
                }
            } catch (IOException unused2) {
            }
        }
        return null;
    }
}
