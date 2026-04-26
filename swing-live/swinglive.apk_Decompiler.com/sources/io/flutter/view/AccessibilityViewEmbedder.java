package io.flutter.view;

import android.graphics.Rect;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.util.SparseArray;
import android.view.MotionEvent;
import android.view.View;
import android.view.accessibility.AccessibilityEvent;
import android.view.accessibility.AccessibilityNodeInfo;
import android.view.accessibility.AccessibilityNodeProvider;
import android.view.accessibility.AccessibilityRecord;
import androidx.annotation.Keep;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Map;

/* JADX INFO: loaded from: classes.dex */
@Keep
class AccessibilityViewEmbedder {
    private static final String TAG = "AccessibilityBridge";
    private int nextFlutterId;
    private final View rootAccessibilityView;
    private final o reflectionAccessors = new o();
    private final SparseArray<p> flutterIdToOrigin = new SparseArray<>();
    private final Map<p, Integer> originToFlutterId = new HashMap();
    private final Map<View, Rect> embeddedViewToDisplayBounds = new HashMap();

    public AccessibilityViewEmbedder(View view, int i4) {
        this.rootAccessibilityView = view;
        this.nextFlutterId = i4;
    }

    private void addChildrenToFlutterNode(AccessibilityNodeInfo accessibilityNodeInfo, View view, AccessibilityNodeInfo accessibilityNodeInfo2) {
        Long l2;
        int iIntValue;
        for (int i4 = 0; i4 < accessibilityNodeInfo.getChildCount(); i4++) {
            o oVar = this.reflectionAccessors;
            Method method = oVar.f4818f;
            Field field = oVar.e;
            Method method2 = oVar.f4817d;
            if (method2 == null && (field == null || method == null)) {
                l2 = null;
            } else if (method2 != null) {
                try {
                    l2 = (Long) method2.invoke(accessibilityNodeInfo, Integer.valueOf(i4));
                } catch (IllegalAccessException e) {
                    Log.w(TAG, "Failed to access getChildId method.", e);
                    l2 = null;
                } catch (InvocationTargetException e4) {
                    Log.w(TAG, "The getChildId method threw an exception when invoked.", e4);
                    l2 = null;
                }
            } else {
                try {
                    l2 = (Long) method.invoke(field.get(accessibilityNodeInfo), Integer.valueOf(i4));
                    l2.getClass();
                } catch (ArrayIndexOutOfBoundsException e5) {
                    e = e5;
                    Log.w(TAG, "The longArrayGetIndex method threw an exception when invoked.", e);
                    l2 = null;
                } catch (IllegalAccessException e6) {
                    Log.w(TAG, "Failed to access longArrayGetIndex method or the childNodeId field.", e6);
                    l2 = null;
                } catch (InvocationTargetException e7) {
                    e = e7;
                    Log.w(TAG, "The longArrayGetIndex method threw an exception when invoked.", e);
                    l2 = null;
                }
            }
            if (l2 != null) {
                int iLongValue = (int) (l2.longValue() >> 32);
                p pVar = new p(view, iLongValue);
                if (this.originToFlutterId.containsKey(pVar)) {
                    iIntValue = this.originToFlutterId.get(pVar).intValue();
                } else {
                    int i5 = this.nextFlutterId;
                    this.nextFlutterId = i5 + 1;
                    cacheVirtualIdMappings(view, iLongValue, i5);
                    iIntValue = i5;
                }
                accessibilityNodeInfo2.addChild(this.rootAccessibilityView, iIntValue);
            }
        }
    }

    private void cacheVirtualIdMappings(View view, int i4, int i5) {
        p pVar = new p(view, i4);
        this.originToFlutterId.put(pVar, Integer.valueOf(i5));
        this.flutterIdToOrigin.put(i5, pVar);
    }

    private AccessibilityNodeInfo convertToFlutterNode(AccessibilityNodeInfo accessibilityNodeInfo, int i4, View view) {
        AccessibilityNodeInfo accessibilityNodeInfoObtain = AccessibilityNodeInfo.obtain(this.rootAccessibilityView, i4);
        accessibilityNodeInfoObtain.setPackageName(this.rootAccessibilityView.getContext().getPackageName());
        accessibilityNodeInfoObtain.setSource(this.rootAccessibilityView, i4);
        accessibilityNodeInfoObtain.setClassName(accessibilityNodeInfo.getClassName());
        Rect rect = this.embeddedViewToDisplayBounds.get(view);
        copyAccessibilityFields(accessibilityNodeInfo, accessibilityNodeInfoObtain);
        setFlutterNodesTranslateBounds(accessibilityNodeInfo, rect, accessibilityNodeInfoObtain);
        addChildrenToFlutterNode(accessibilityNodeInfo, view, accessibilityNodeInfoObtain);
        setFlutterNodeParent(accessibilityNodeInfo, view, accessibilityNodeInfoObtain);
        return accessibilityNodeInfoObtain;
    }

    private void copyAccessibilityFields(AccessibilityNodeInfo accessibilityNodeInfo, AccessibilityNodeInfo accessibilityNodeInfo2) {
        accessibilityNodeInfo2.setAccessibilityFocused(accessibilityNodeInfo.isAccessibilityFocused());
        accessibilityNodeInfo2.setCheckable(accessibilityNodeInfo.isCheckable());
        accessibilityNodeInfo2.setChecked(accessibilityNodeInfo.isChecked());
        accessibilityNodeInfo2.setContentDescription(accessibilityNodeInfo.getContentDescription());
        accessibilityNodeInfo2.setEnabled(accessibilityNodeInfo.isEnabled());
        accessibilityNodeInfo2.setClickable(accessibilityNodeInfo.isClickable());
        accessibilityNodeInfo2.setFocusable(accessibilityNodeInfo.isFocusable());
        accessibilityNodeInfo2.setFocused(accessibilityNodeInfo.isFocused());
        accessibilityNodeInfo2.setLongClickable(accessibilityNodeInfo.isLongClickable());
        accessibilityNodeInfo2.setMovementGranularities(accessibilityNodeInfo.getMovementGranularities());
        accessibilityNodeInfo2.setPassword(accessibilityNodeInfo.isPassword());
        accessibilityNodeInfo2.setScrollable(accessibilityNodeInfo.isScrollable());
        accessibilityNodeInfo2.setSelected(accessibilityNodeInfo.isSelected());
        accessibilityNodeInfo2.setText(accessibilityNodeInfo.getText());
        accessibilityNodeInfo2.setVisibleToUser(accessibilityNodeInfo.isVisibleToUser());
        accessibilityNodeInfo2.setEditable(accessibilityNodeInfo.isEditable());
        accessibilityNodeInfo2.setCanOpenPopup(accessibilityNodeInfo.canOpenPopup());
        accessibilityNodeInfo2.setCollectionInfo(accessibilityNodeInfo.getCollectionInfo());
        accessibilityNodeInfo2.setCollectionItemInfo(accessibilityNodeInfo.getCollectionItemInfo());
        accessibilityNodeInfo2.setContentInvalid(accessibilityNodeInfo.isContentInvalid());
        accessibilityNodeInfo2.setDismissable(accessibilityNodeInfo.isDismissable());
        accessibilityNodeInfo2.setInputType(accessibilityNodeInfo.getInputType());
        accessibilityNodeInfo2.setLiveRegion(accessibilityNodeInfo.getLiveRegion());
        accessibilityNodeInfo2.setMultiLine(accessibilityNodeInfo.isMultiLine());
        accessibilityNodeInfo2.setRangeInfo(accessibilityNodeInfo.getRangeInfo());
        accessibilityNodeInfo2.setError(accessibilityNodeInfo.getError());
        accessibilityNodeInfo2.setMaxTextLength(accessibilityNodeInfo.getMaxTextLength());
        accessibilityNodeInfo2.setContextClickable(accessibilityNodeInfo.isContextClickable());
        accessibilityNodeInfo2.setDrawingOrder(accessibilityNodeInfo.getDrawingOrder());
        accessibilityNodeInfo2.setImportantForAccessibility(accessibilityNodeInfo.isImportantForAccessibility());
        if (Build.VERSION.SDK_INT >= 26) {
            accessibilityNodeInfo2.setAvailableExtraData(accessibilityNodeInfo.getAvailableExtraData());
            accessibilityNodeInfo2.setHintText(accessibilityNodeInfo.getHintText());
            accessibilityNodeInfo2.setShowingHintText(accessibilityNodeInfo.isShowingHintText());
        }
    }

    /* JADX WARN: Removed duplicated region for block: B:14:0x002b  */
    /* JADX WARN: Removed duplicated region for block: B:16:0x0032  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    private void setFlutterNodeParent(android.view.accessibility.AccessibilityNodeInfo r6, android.view.View r7, android.view.accessibility.AccessibilityNodeInfo r8) {
        /*
            r5 = this;
            io.flutter.view.o r0 = r5.reflectionAccessors
            java.lang.reflect.Method r0 = r0.f4815b
            r1 = 0
            java.lang.String r2 = "AccessibilityBridge"
            if (r0 == 0) goto L24
            java.lang.Object[] r3 = new java.lang.Object[r1]     // Catch: java.lang.reflect.InvocationTargetException -> L15 java.lang.IllegalAccessException -> L17
            java.lang.Object r0 = r0.invoke(r6, r3)     // Catch: java.lang.reflect.InvocationTargetException -> L15 java.lang.IllegalAccessException -> L17
            java.lang.Long r0 = (java.lang.Long) r0     // Catch: java.lang.reflect.InvocationTargetException -> L15 java.lang.IllegalAccessException -> L17
            r0.getClass()     // Catch: java.lang.reflect.InvocationTargetException -> L15 java.lang.IllegalAccessException -> L17
            goto L77
        L15:
            r0 = move-exception
            goto L19
        L17:
            r0 = move-exception
            goto L1f
        L19:
            java.lang.String r3 = "The getParentNodeId method threw an exception when invoked."
            android.util.Log.w(r2, r3, r0)
            goto L24
        L1f:
            java.lang.String r3 = "Failed to access getParentNodeId method."
            android.util.Log.w(r2, r3, r0)
        L24:
            int r0 = android.os.Build.VERSION.SDK_INT
            r3 = 26
            r4 = 0
            if (r0 >= r3) goto L32
            java.lang.String r6 = "Unexpected Android version. Unable to find the parent ID."
            android.util.Log.w(r2, r6)
        L30:
            r0 = r4
            goto L77
        L32:
            android.view.accessibility.AccessibilityNodeInfo r6 = android.view.accessibility.AccessibilityNodeInfo.obtain(r6)
            android.os.Parcel r0 = android.os.Parcel.obtain()
            r0.setDataPosition(r1)
            r6.writeToParcel(r0, r1)
            r0.setDataPosition(r1)
            long r2 = r0.readLong()
            boolean r6 = io.flutter.view.o.b(r1, r2)
            if (r6 == 0) goto L50
            r0.readInt()
        L50:
            r6 = 1
            boolean r6 = io.flutter.view.o.b(r6, r2)
            if (r6 == 0) goto L5a
            r0.readLong()
        L5a:
            r6 = 2
            boolean r6 = io.flutter.view.o.b(r6, r2)
            if (r6 == 0) goto L64
            r0.readInt()
        L64:
            r6 = 3
            boolean r6 = io.flutter.view.o.b(r6, r2)
            if (r6 == 0) goto L73
            long r1 = r0.readLong()
            java.lang.Long r4 = java.lang.Long.valueOf(r1)
        L73:
            r0.recycle()
            goto L30
        L77:
            if (r0 != 0) goto L7a
            goto L9a
        L7a:
            long r0 = r0.longValue()
            r6 = 32
            long r0 = r0 >> r6
            int r6 = (int) r0
            java.util.Map<io.flutter.view.p, java.lang.Integer> r0 = r5.originToFlutterId
            io.flutter.view.p r1 = new io.flutter.view.p
            r1.<init>(r7, r6)
            java.lang.Object r6 = r0.get(r1)
            java.lang.Integer r6 = (java.lang.Integer) r6
            if (r6 == 0) goto L9a
            android.view.View r7 = r5.rootAccessibilityView
            int r6 = r6.intValue()
            r8.setParent(r7, r6)
        L9a:
            return
        */
        throw new UnsupportedOperationException("Method not decompiled: io.flutter.view.AccessibilityViewEmbedder.setFlutterNodeParent(android.view.accessibility.AccessibilityNodeInfo, android.view.View, android.view.accessibility.AccessibilityNodeInfo):void");
    }

    private void setFlutterNodesTranslateBounds(AccessibilityNodeInfo accessibilityNodeInfo, Rect rect, AccessibilityNodeInfo accessibilityNodeInfo2) {
        Rect rect2 = new Rect();
        accessibilityNodeInfo.getBoundsInParent(rect2);
        accessibilityNodeInfo2.setBoundsInParent(rect2);
        Rect rect3 = new Rect();
        accessibilityNodeInfo.getBoundsInScreen(rect3);
        rect3.offset(rect.left, rect.top);
        accessibilityNodeInfo2.setBoundsInScreen(rect3);
    }

    public AccessibilityNodeInfo createAccessibilityNodeInfo(int i4) {
        AccessibilityNodeInfo accessibilityNodeInfoCreateAccessibilityNodeInfo;
        p pVar = this.flutterIdToOrigin.get(i4);
        if (pVar == null) {
            return null;
        }
        Map<View, Rect> map = this.embeddedViewToDisplayBounds;
        View view = pVar.f4819a;
        if (!map.containsKey(view) || view.getAccessibilityNodeProvider() == null || (accessibilityNodeInfoCreateAccessibilityNodeInfo = view.getAccessibilityNodeProvider().createAccessibilityNodeInfo(pVar.f4820b)) == null) {
            return null;
        }
        return convertToFlutterNode(accessibilityNodeInfoCreateAccessibilityNodeInfo, i4, view);
    }

    public Integer getRecordFlutterId(View view, AccessibilityRecord accessibilityRecord) {
        Long lA = o.a(this.reflectionAccessors, accessibilityRecord);
        if (lA == null) {
            return null;
        }
        return this.originToFlutterId.get(new p(view, (int) (lA.longValue() >> 32)));
    }

    public AccessibilityNodeInfo getRootNode(View view, int i4, Rect rect) {
        Long l2;
        AccessibilityNodeInfo accessibilityNodeInfoCreateAccessibilityNodeInfo = view.createAccessibilityNodeInfo();
        Method method = this.reflectionAccessors.f4814a;
        if (method == null) {
            l2 = null;
        } else {
            try {
                l2 = (Long) method.invoke(accessibilityNodeInfoCreateAccessibilityNodeInfo, new Object[0]);
            } catch (IllegalAccessException e) {
                Log.w(TAG, "Failed to access getSourceNodeId method.", e);
                l2 = null;
            } catch (InvocationTargetException e4) {
                Log.w(TAG, "The getSourceNodeId method threw an exception when invoked.", e4);
                l2 = null;
            }
        }
        if (l2 == null) {
            return null;
        }
        this.embeddedViewToDisplayBounds.put(view, rect);
        cacheVirtualIdMappings(view, (int) (l2.longValue() >> 32), i4);
        return convertToFlutterNode(accessibilityNodeInfoCreateAccessibilityNodeInfo, i4, view);
    }

    public boolean onAccessibilityHoverEvent(int i4, MotionEvent motionEvent) {
        p pVar = this.flutterIdToOrigin.get(i4);
        if (pVar == null) {
            return false;
        }
        Map<View, Rect> map = this.embeddedViewToDisplayBounds;
        View view = pVar.f4819a;
        Rect rect = map.get(view);
        int pointerCount = motionEvent.getPointerCount();
        MotionEvent.PointerProperties[] pointerPropertiesArr = new MotionEvent.PointerProperties[pointerCount];
        MotionEvent.PointerCoords[] pointerCoordsArr = new MotionEvent.PointerCoords[pointerCount];
        for (int i5 = 0; i5 < motionEvent.getPointerCount(); i5++) {
            MotionEvent.PointerProperties pointerProperties = new MotionEvent.PointerProperties();
            pointerPropertiesArr[i5] = pointerProperties;
            motionEvent.getPointerProperties(i5, pointerProperties);
            MotionEvent.PointerCoords pointerCoords = new MotionEvent.PointerCoords();
            motionEvent.getPointerCoords(i5, pointerCoords);
            MotionEvent.PointerCoords pointerCoords2 = new MotionEvent.PointerCoords(pointerCoords);
            pointerCoordsArr[i5] = pointerCoords2;
            pointerCoords2.x -= rect.left;
            pointerCoords2.y -= rect.top;
        }
        return view.dispatchGenericMotionEvent(MotionEvent.obtain(motionEvent.getDownTime(), motionEvent.getEventTime(), motionEvent.getAction(), motionEvent.getPointerCount(), pointerPropertiesArr, pointerCoordsArr, motionEvent.getMetaState(), motionEvent.getButtonState(), motionEvent.getXPrecision(), motionEvent.getYPrecision(), motionEvent.getDeviceId(), motionEvent.getEdgeFlags(), motionEvent.getSource(), motionEvent.getFlags()));
    }

    public boolean performAction(int i4, int i5, Bundle bundle) {
        AccessibilityNodeProvider accessibilityNodeProvider;
        p pVar = this.flutterIdToOrigin.get(i4);
        if (pVar == null || (accessibilityNodeProvider = pVar.f4819a.getAccessibilityNodeProvider()) == null) {
            return false;
        }
        return accessibilityNodeProvider.performAction(pVar.f4820b, i5, bundle);
    }

    public View platformViewOfNode(int i4) {
        p pVar = this.flutterIdToOrigin.get(i4);
        if (pVar == null) {
            return null;
        }
        return pVar.f4819a;
    }

    public boolean requestSendAccessibilityEvent(View view, View view2, AccessibilityEvent accessibilityEvent) {
        AccessibilityEvent accessibilityEventObtain = AccessibilityEvent.obtain(accessibilityEvent);
        Long lA = o.a(this.reflectionAccessors, accessibilityEvent);
        if (lA != null) {
            int iLongValue = (int) (lA.longValue() >> 32);
            Integer num = this.originToFlutterId.get(new p(view, iLongValue));
            if (num == null) {
                int i4 = this.nextFlutterId;
                this.nextFlutterId = i4 + 1;
                Integer numValueOf = Integer.valueOf(i4);
                cacheVirtualIdMappings(view, iLongValue, i4);
                num = numValueOf;
            }
            accessibilityEventObtain.setSource(this.rootAccessibilityView, num.intValue());
            accessibilityEventObtain.setClassName(accessibilityEvent.getClassName());
            accessibilityEventObtain.setPackageName(accessibilityEvent.getPackageName());
            for (int i5 = 0; i5 < accessibilityEventObtain.getRecordCount(); i5++) {
                AccessibilityRecord record = accessibilityEventObtain.getRecord(i5);
                Long lA2 = o.a(this.reflectionAccessors, record);
                if (lA2 != null) {
                    p pVar = new p(view, (int) (lA2.longValue() >> 32));
                    if (this.originToFlutterId.containsKey(pVar)) {
                        record.setSource(this.rootAccessibilityView, this.originToFlutterId.get(pVar).intValue());
                    }
                }
            }
            return this.rootAccessibilityView.getParent().requestSendAccessibilityEvent(view2, accessibilityEventObtain);
        }
        return false;
    }
}
