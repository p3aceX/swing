package io.flutter.view;

import android.os.Build;
import android.util.Log;
import android.view.accessibility.AccessibilityNodeInfo;
import android.view.accessibility.AccessibilityRecord;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

/* JADX INFO: loaded from: classes.dex */
public final class o {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Method f4814a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final Method f4815b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final Method f4816c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final Method f4817d;
    public final Field e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final Method f4818f;

    /* JADX WARN: Multi-variable type inference failed */
    public o() throws NoSuchMethodException {
        Method method;
        Method method2;
        Method method3;
        Method method4;
        Field field;
        Method method5;
        Method method6 = null;
        try {
            method = AccessibilityNodeInfo.class.getMethod("getSourceNodeId", new Class[0]);
        } catch (NoSuchMethodException unused) {
            Log.w("AccessibilityBridge", "can't invoke AccessibilityNodeInfo#getSourceNodeId with reflection");
            method = null;
        }
        try {
            method2 = AccessibilityRecord.class.getMethod("getSourceNodeId", new Class[0]);
        } catch (NoSuchMethodException unused2) {
            Log.w("AccessibilityBridge", "can't invoke AccessibiiltyRecord#getSourceNodeId with reflection");
            method2 = null;
        }
        int i4 = Build.VERSION.SDK_INT;
        Class cls = Integer.TYPE;
        if (i4 > 26) {
            try {
                Field declaredField = AccessibilityNodeInfo.class.getDeclaredField("mChildNodeIds");
                declaredField.setAccessible(true);
                method5 = Class.forName("android.util.LongArray").getMethod("get", cls);
                field = declaredField;
                method4 = null;
            } catch (ClassNotFoundException | NoSuchFieldException | NoSuchMethodException | NullPointerException unused3) {
                Log.w("AccessibilityBridge", "can't access childNodeIdsField with reflection");
                method4 = null;
                field = null;
                method5 = field;
            }
            this.f4814a = method;
            this.f4815b = method6;
            this.f4816c = method2;
            this.f4817d = method4;
            this.e = field;
            this.f4818f = method5;
        }
        try {
            method3 = AccessibilityNodeInfo.class.getMethod("getParentNodeId", new Class[0]);
        } catch (NoSuchMethodException unused4) {
            Log.w("AccessibilityBridge", "can't invoke getParentNodeId with reflection");
            method3 = null;
        }
        try {
            method4 = AccessibilityNodeInfo.class.getMethod("getChildId", cls);
            field = null;
        } catch (NoSuchMethodException unused5) {
            Log.w("AccessibilityBridge", "can't invoke getChildId with reflection");
            method4 = null;
            field = null;
        }
        method6 = method3;
        method5 = field;
        this.f4814a = method;
        this.f4815b = method6;
        this.f4816c = method2;
        this.f4817d = method4;
        this.e = field;
        this.f4818f = method5;
    }

    public static Long a(o oVar, AccessibilityRecord accessibilityRecord) {
        Method method = oVar.f4816c;
        if (method == null) {
            return null;
        }
        try {
            return (Long) method.invoke(accessibilityRecord, new Object[0]);
        } catch (IllegalAccessException e) {
            Log.w("AccessibilityBridge", "Failed to access the getRecordSourceNodeId method.", e);
            return null;
        } catch (InvocationTargetException e4) {
            Log.w("AccessibilityBridge", "The getRecordSourceNodeId method threw an exception when invoked.", e4);
            return null;
        }
    }

    public static boolean b(int i4, long j4) {
        return (j4 & (1 << i4)) != 0;
    }
}
